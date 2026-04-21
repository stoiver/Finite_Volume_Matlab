"""
Narrabundah Reservoir — ANUGA Simulation
Converted from narrabundah_anuga_v2.ipynb

Prerequisites: run exportNarrabundahMesh.m in Octave first to produce
narrabundah_nodes.csv and narrabundah_triangles.csv in this directory.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as mtri
import matplotlib.animation as animation
import anuga
import contextily as ctx
from collections import defaultdict
from scipy.interpolate import LinearNDInterpolator, NearestNDInterpolator
from scipy.spatial import ConvexHull
from matplotlib.path import Path

# ---------------------------------------------------------------------------
# 1. Load exported mesh data
# ---------------------------------------------------------------------------
nodes     = np.loadtxt('narrabundah_nodes.csv', delimiter=',')
triangles = np.loadtxt('narrabundah_triangles.csv', delimiter=',', dtype=int)

points     = nodes[:, 0:2]
elevation  = nodes[:, 2]
friction   = nodes[:, 3]
init_depth = nodes[:, 4]

print(f'Loaded mesh: {len(points)} nodes, {len(triangles)} triangles')
print(f'x range:         [{points[:,0].min():.1f}, {points[:,0].max():.1f}]')
print(f'y range:         [{points[:,1].min():.1f}, {points[:,1].max():.1f}]')
print(f'elevation range: [{elevation.min():.1f}, {elevation.max():.1f}] m')

# Visualise original mesh elevation
fig, ax = plt.subplots(figsize=(8, 6))
tc = ax.tripcolor(points[:,0], points[:,1], triangles, elevation, cmap='terrain')
plt.colorbar(tc, ax=ax, label='Elevation (m)')
ax.set_title('Original mesh — elevation')
ax.set_aspect('equal')
plt.tight_layout()
plt.savefig('narrabundah_orig_elevation.png', dpi=150)
plt.close()

# ---------------------------------------------------------------------------
# 2. Extract boundary polygon
# ---------------------------------------------------------------------------
edge_map = defaultdict(list)
for tri_idx, tri in enumerate(triangles):
    for k in range(3):
        n0, n1 = tri[k], tri[(k + 1) % 3]
        edge = (min(n0, n1), max(n0, n1))
        edge_map[edge].append((tri_idx, k))

boundary_adj = defaultdict(list)
for edge, tris in edge_map.items():
    if len(tris) == 1:
        n0, n1 = edge
        boundary_adj[n0].append(n1)
        boundary_adj[n1].append(n0)

def signed_area(poly):
    n = len(poly)
    return sum(poly[i][0] * poly[(i+1)%n][1] -
               poly[(i+1)%n][0] * poly[i][1] for i in range(n)) / 2.0

def trace_boundary_loops(adj):
    unvisited = set(adj.keys())
    loops = []
    while unvisited:
        start = min(unvisited)
        loop = [start]
        unvisited.discard(start)
        prev, current = None, start
        while True:
            candidates = [n for n in adj[current] if n != prev]
            if not candidates or candidates[0] == start:
                break
            nxt = candidates[0]
            if nxt not in unvisited:
                break
            loop.append(nxt)
            unvisited.discard(nxt)
            prev, current = current, nxt
        loops.append(loop)
    return loops

loops = trace_boundary_loops(boundary_adj)
loop_areas = [abs(signed_area(points[l].tolist())) for l in loops]

print(f'Found {len(loops)} boundary loops')
print(f'Loop sizes (vertices): {sorted([len(l) for l in loops], reverse=True)}')
print(f'Loop areas (m²):       {[f"{a:.0f}" for a in sorted(loop_areas, reverse=True)]}')

extreme_node = int(np.argmin(points[:, 1]))
print(f'\nExtreme node {extreme_node}: x={points[extreme_node,0]:.1f}, '
      f'y={points[extreme_node,1]:.1f}, elev={elevation[extreme_node]:.1f} m')

boundary_node_sets = [set(loop) for loop in loops]
outer_loop = None
for loop, node_set in zip(loops, boundary_node_sets):
    if extreme_node in node_set:
        outer_loop = loop
        break

if outer_loop is None:
    print('WARNING: extreme node not on any loop - falling back to largest area')
    outer_loop = loops[int(np.argmax(loop_areas))]
else:
    print(f'Outer loop found via extreme node: {len(outer_loop)} vertices')

bounding_polygon = points[outer_loop].tolist()
print(f'Outer boundary extent:')
print(f'  x=[{points[outer_loop,0].min():.1f}, {points[outer_loop,0].max():.1f}]')
print(f'  y=[{points[outer_loop,1].min():.1f}, {points[outer_loop,1].max():.1f}]')
print(f'  elev=[{elevation[outer_loop].min():.1f}, {elevation[outer_loop].max():.1f}] m')

if signed_area(bounding_polygon) < 0:
    bounding_polygon = bounding_polygon[::-1]

# Visualise boundary loops
fig, ax = plt.subplots(figsize=(8, 6))
ax.triplot(points[:,0], points[:,1], triangles, lw=0.3, color='lightgrey')
bp = np.array(bounding_polygon)
ax.plot(np.append(bp[:,0], bp[0,0]), np.append(bp[:,1], bp[0,1]),
        'r-', lw=1.5, label=f'Outer boundary ({len(bounding_polygon)} pts)')
for loop in loops:
    if loop is not outer_loop:
        lp = points[loop]
        ax.plot(np.append(lp[:,0], lp[0,0]), np.append(lp[:,1], lp[0,1]),
                'b--', lw=0.8, alpha=0.6)
ax.set_title('Boundary loops  (red = outer, blue dashed = discarded)')
ax.set_aspect('equal')
ax.legend()
plt.tight_layout()
plt.savefig('narrabundah_boundary_loops.png', dpi=150)
plt.close()

# ---------------------------------------------------------------------------
# 3. Build reservoir polygon
# ---------------------------------------------------------------------------
reservoir_mask = init_depth > 0
reservoir_pts  = points[reservoir_mask]
print(f'Reservoir nodes: {reservoir_mask.sum()}')
print(f'  x=[{reservoir_pts[:,0].min():.1f}, {reservoir_pts[:,0].max():.1f}]')
print(f'  y=[{reservoir_pts[:,1].min():.1f}, {reservoir_pts[:,1].max():.1f}]')
print(f'  init_depth: [{init_depth[reservoir_mask].min():.3f}, {init_depth[reservoir_mask].max():.3f}] m')

hull = ConvexHull(reservoir_pts)
reservoir_polygon = reservoir_pts[hull.vertices].tolist()
if signed_area(reservoir_polygon) < 0:
    reservoir_polygon = reservoir_polygon[::-1]

# Visualise reservoir polygon
fig, ax = plt.subplots(figsize=(8, 6))
ax.triplot(points[:,0], points[:,1], triangles, lw=0.3, color='lightgrey')
bp = np.array(bounding_polygon)
ax.plot(np.append(bp[:,0], bp[0,0]), np.append(bp[:,1], bp[0,1]),
        'r-', lw=1.5, label='Outer boundary')
rp = np.array(reservoir_polygon)
ax.plot(np.append(rp[:,0], rp[0,0]), np.append(rp[:,1], rp[0,1]),
        'b-', lw=1.5, label='Reservoir polygon')
ax.set_title('Outer boundary and reservoir polygon')
ax.set_aspect('equal')
ax.legend()
plt.tight_layout()
plt.savefig('narrabundah_reservoir_polygon.png', dpi=150)
plt.close()

# ---------------------------------------------------------------------------
# 4. Create ANUGA domain
# ---------------------------------------------------------------------------
max_tri_area       = 150.0
reservoir_tri_area = 20.0

boundary_tags = {'exterior': list(range(len(bounding_polygon)))}

domain = anuga.create_domain_from_regions(
    bounding_polygon,
    boundary_tags=boundary_tags,
    maximum_triangle_area=max_tri_area,
    interior_regions=[(reservoir_polygon, reservoir_tri_area)],
)
domain.set_name('narrabundah_v2')
domain.set_datadir('.')
domain.set_default_order(2)

print(f'New mesh: {domain.get_number_of_nodes()} nodes, '
      f'{domain.get_number_of_triangles()} triangles')

# ---------------------------------------------------------------------------
# 5. Set elevation
# ---------------------------------------------------------------------------
interp_linear  = LinearNDInterpolator(points, elevation)
interp_nearest = NearestNDInterpolator(points, elevation)

xllcorner = domain.geo_reference.get_xllcorner()
yllcorner = domain.geo_reference.get_yllcorner()
print(f'Geo-reference offset: xllcorner={xllcorner:.2f}, yllcorner={yllcorner:.2f}')

def elevation_func(x, y):
    x_abs = x + xllcorner
    y_abs = y + yllcorner
    z = interp_linear(x_abs, y_abs)
    nan_mask = np.isnan(z)
    if nan_mask.any():
        z[nan_mask] = interp_nearest(x_abs[nan_mask], y_abs[nan_mask])
    return z

domain.set_quantity('elevation', elevation_func, location='centroids')
domain.set_quantity('friction', 0.03, location='centroids')

x_c    = domain.centroid_coordinates[:, 0]
y_c    = domain.centroid_coordinates[:, 1]
elev_c = domain.quantities['elevation'].centroid_values.copy()

print(f'Elevation on new mesh: [{elev_c.min():.1f}, {elev_c.max():.1f}] m')
print(f'Elevation on original: [{elevation.min():.1f}, {elevation.max():.1f}] m')

# ---------------------------------------------------------------------------
# 5a. Set UTM geo-reference (EPSG:32755, zone 55S)
# ---------------------------------------------------------------------------
UTM_RES_E = 693947.7856
UTM_RES_N = 6086616.5080

res_centre_local_x = reservoir_pts[:, 0].mean()
res_centre_local_y = reservoir_pts[:, 1].mean()
print(f'Reservoir centroid (local):  x={res_centre_local_x:.4f} m,  y={res_centre_local_y:.4f} m')

utm_x_origin = UTM_RES_E - res_centre_local_x
utm_y_origin = UTM_RES_N - res_centre_local_y
print(f'UTM of local origin (0, 0):  E={utm_x_origin:.4f} m,  N={utm_y_origin:.4f} m')

xllcorner_utm = utm_x_origin + xllcorner
yllcorner_utm = utm_y_origin + yllcorner
print(f'\nGeo-reference (EPSG:32755 — UTM zone 55S, WGS84):')
print(f'  xllcorner = {xllcorner_utm:.4f} m')
print(f'  yllcorner = {yllcorner_utm:.4f} m')

domain.geo_reference = anuga.Geo_reference(epsg=32755, xllcorner=xllcorner_utm, yllcorner=yllcorner_utm)

x_min_utm = xllcorner_utm + domain.get_nodes()[:, 0].min()
x_max_utm = xllcorner_utm + domain.get_nodes()[:, 0].max()
y_min_utm = yllcorner_utm + domain.get_nodes()[:, 1].min()
y_max_utm = yllcorner_utm + domain.get_nodes()[:, 1].max()
print(f'\nDomain extent (UTM zone 55S):')
print(f'  Easting:  [{x_min_utm:.1f}, {x_max_utm:.1f}] m')
print(f'  Northing: [{y_min_utm:.1f}, {y_max_utm:.1f}] m')

# Visualise new mesh elevation vs original
new_verts = domain.get_nodes()
new_tris  = domain.get_triangles()
new_verts_abs = new_verts + np.array([xllcorner, yllcorner])

fig, axes = plt.subplots(1, 2, figsize=(14, 5))
tc0 = axes[0].tripcolor(points[:,0], points[:,1], triangles, elevation, cmap='terrain')
plt.colorbar(tc0, ax=axes[0], label='Elevation (m)')
axes[0].set_title('Original mesh')
axes[0].set_aspect('equal')
tc1 = axes[1].tripcolor(new_verts_abs[:,0], new_verts_abs[:,1], new_tris, elev_c, cmap='terrain')
plt.colorbar(tc1, ax=axes[1], label='Elevation (m)')
axes[1].set_title('New ANUGA mesh')
axes[1].set_aspect('equal')
plt.tight_layout()
plt.savefig('comparison.png', dpi=150)
plt.close()

# ---------------------------------------------------------------------------
# 6. Set initial stage
# ---------------------------------------------------------------------------
x_c_abs = x_c + xllcorner
y_c_abs = y_c + yllcorner

res_path = Path(reservoir_polygon + [reservoir_polygon[0]])
in_res   = res_path.contains_points(np.column_stack([x_c_abs, y_c_abs]))

mean_res_elev = elev_c[in_res].mean()
reservoir_stage = mean_res_elev + 7.7
print(f'Reservoir triangles with water: {in_res.sum()}')
print(f'Mean bed elevation in reservoir: {mean_res_elev:.2f} m')
print(f'Constant water surface (stage):  {reservoir_stage:.2f} m')

stage_c = elev_c.copy()
stage_c[in_res] = reservoir_stage

if in_res.sum() > 0:
    depth_res = stage_c[in_res] - elev_c[in_res]
    print(f'Depth range in reservoir: [{depth_res.min():.2f}, {depth_res.max():.2f}] m')
else:
    print('WARNING: no reservoir triangles found — check reservoir polygon vs mesh extent')

domain.set_quantity('stage', stage_c, location='centroids')

# Visualise initial stage
depth_c = np.maximum(stage_c - elev_c, 0.0)
triang_init = mtri.Triangulation(new_verts_abs[:, 0], new_verts_abs[:, 1], new_tris)
triang_init.set_mask(depth_c < 0.001)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))
tc0 = axes[0].tripcolor(new_verts_abs[:,0], new_verts_abs[:,1], new_tris, stage_c, cmap='Blues')
plt.colorbar(tc0, ax=axes[0], label='Stage (m)')
axes[0].set_title('Initial stage')
axes[0].set_aspect('equal')
tc1 = axes[1].tripcolor(triang_init, depth_c, cmap='Blues', vmin=0.0)
plt.colorbar(tc1, ax=axes[1], label='Depth (m)')
axes[1].set_title('Initial water depth')
axes[1].set_aspect('equal')
plt.tight_layout()
plt.savefig('narrabundah_initial_stage.png', dpi=150)
plt.close()

# ---------------------------------------------------------------------------
# 7. Boundary conditions and run
# ---------------------------------------------------------------------------
Bt = anuga.Transmissive_boundary(domain)
domain.set_boundary({'exterior': Bt})

yieldstep = 0.5
finaltime = 50.0

domain.set_plotter(plot_dir='_plot', min_depth=0.01)
vmax = 1.0

print(f'Running: finaltime={finaltime}s, yieldstep={yieldstep}s')
for t in domain.evolve(yieldstep=yieldstep, finaltime=finaltime):
    domain.print_timestepping_statistics()
    domain.save_depth_frame(vmin=0.0, vmax=vmax)

# ---------------------------------------------------------------------------
# 8. Create animation
# ---------------------------------------------------------------------------
domain.make_depth_animation()

# ---------------------------------------------------------------------------
# 9. Plot depth, speed and momentum over OpenStreetMap at selected times
# ---------------------------------------------------------------------------
sww = anuga.SWW_plotter('narrabundah_v2.sww', plot_dir=None, min_depth=0.001)

sww_verts_utm = np.column_stack([sww.x + sww.xllcorner, sww.y + sww.yllcorner])
sww_tris      = sww.triangles

elev_nodes_sww   = elevation_func(sww.x, sww.y)
elev_min_s       = np.floor(elev_nodes_sww.min() / 5) * 5
elev_max_s       = np.ceil(elev_nodes_sww.max()  / 5) * 5
contour_levels_s = np.arange(elev_min_s, elev_max_s + 5, 5)

triang_full_sww = mtri.Triangulation(sww_verts_utm[:, 0], sww_verts_utm[:, 1], sww_tris)

print(f'SWW file: {len(sww.time)} frames,  t = [{sww.time[0]:.1f}, {sww.time[-1]:.1f}] s')

target_times = [0, 2, 5, 10, 20, 50]

frames = []
for t_target in target_times:
    idx      = int(np.argmin(np.abs(sww.time - t_target)))
    t_actual = sww.time[idx]
    depth    = sww.depth[idx]
    xmom     = sww.xmom[idx]
    ymom     = sww.ymom[idx]
    wet      = depth > 0.001
    speed    = np.where(wet,
                        np.sqrt((xmom / np.where(wet, depth, 1.0))**2 +
                                (ymom / np.where(wet, depth, 1.0))**2),
                        0.0)
    momentum = np.sqrt(xmom**2 + ymom**2)
    frames.append(dict(t=t_actual, depth=depth, speed=speed,
                       momentum=momentum, wet=wet))

depth_vmax    = max(f['depth'][f['wet']].max()    for f in frames if f['wet'].any())
speed_vmax    = max(f['speed'][f['wet']].max()    for f in frames if f['wet'].any())
momentum_vmax = max(f['momentum'][f['wet']].max() for f in frames if f['wet'].any())

quantities = [
    ('depth',    'Water depth (m)',  'Blues',   depth_vmax),
    ('speed',    'Flow speed (m/s)', 'YlOrRd',  speed_vmax),
    ('momentum', 'Momentum (m²/s)',  'Purples', momentum_vmax),
]

for f in frames:
    t_actual = f['t']
    wet      = f['wet']
    triang_wet_sww = mtri.Triangulation(sww_verts_utm[:, 0], sww_verts_utm[:, 1], sww_tris)
    triang_wet_sww.set_mask(~wet)

    for qname, label, cmap, vmax_val in quantities:
        values = f[qname]

        fig, ax = plt.subplots(figsize=(9, 7))

        tc = ax.tripcolor(triang_wet_sww, values, cmap=cmap, alpha=0.75,
                          vmin=0.0, vmax=vmax_val)
        plt.colorbar(tc, ax=ax, label=label, shrink=0.85)

        cs = ax.tricontour(triang_full_sww, elev_nodes_sww,
                           levels=contour_levels_s,
                           colors='dimgray', linewidths=0.6, alpha=0.7)
        ax.clabel(cs, fmt='%g m', fontsize=6, inline=True, inline_spacing=2)

        ctx.add_basemap(ax, crs='EPSG:32755',
                        source=ctx.providers.OpenStreetMap.Mapnik,
                        zoom='auto', attribution_size=6)
        ax.set_aspect('equal')
        ax.set_xlabel('Easting (m)')
        ax.set_ylabel('Northing (m)')
        ax.ticklabel_format(style='plain', axis='both')
        ax.set_title(f'{label}  —  t = {t_actual:.1f} s')

        plt.tight_layout()
        fname = f'narrabundah_{qname}_t{int(round(t_actual)):05d}.png'
        plt.savefig(fname, dpi=150, bbox_inches='tight')
        plt.close()
        print(f'Saved {fname}')

# ---------------------------------------------------------------------------
# 10. Save mesh to TSH
# ---------------------------------------------------------------------------
domain.save_mesh_to_tsh('narrabundah_v2.tsh')
print('Done.')
