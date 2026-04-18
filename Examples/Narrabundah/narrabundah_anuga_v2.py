"""
narrabundah_anuga_v2.py

ANUGA shallow water simulation of the Narrabundah reservoir using
create_domain_from_regions with:
  - Boundary polygon extracted from the original triangulation
  - Reservoir interior region for local mesh refinement
  - Elevation interpolated from exported node data (narrabundah_nodes.csv)
  - Initial stage = elevation (dry) except inside reservoir where depth = 7.7m

Requires narrabundah_nodes.csv and narrabundah_triangles.csv produced by
exportNarrabundahMesh.m in Octave.

Run interactively in VSCode: each # %% block is an executable cell.
Run Shift+Enter to execute the current cell and step through.
"""

# %% -------------------------------------------------------------------------
# Imports
# ---------------------------------------------------------------------------
import numpy as np
import matplotlib.pyplot as plt
import anuga
from collections import defaultdict
from scipy.interpolate import LinearNDInterpolator, NearestNDInterpolator
from scipy.spatial import ConvexHull
from matplotlib.path import Path

# %% -------------------------------------------------------------------------
# Load exported mesh data
# Columns: x, y, elevation, friction, initial_depth
# ---------------------------------------------------------------------------
nodes     = np.loadtxt('narrabundah_nodes.csv', delimiter=',')
triangles = np.loadtxt('narrabundah_triangles.csv', delimiter=',', dtype=int)

points     = nodes[:, 0:2]   # (np, 2)  x,y coordinates
elevation  = nodes[:, 2]     # (np,)    bed elevation (m)
friction   = nodes[:, 3]     # (np,)    Manning's n
init_depth = nodes[:, 4]     # (np,)    initial depth — non-zero at reservoir nodes only

print(f'Loaded mesh: {len(points)} nodes, {len(triangles)} triangles')
print(f'x range: [{points[:,0].min():.1f}, {points[:,0].max():.1f}]')
print(f'y range: [{points[:,1].min():.1f}, {points[:,1].max():.1f}]')
print(f'elevation range: [{elevation.min():.1f}, {elevation.max():.1f}]')

# %% -------------------------------------------------------------------------
# Visualise original mesh and elevation — sanity check before proceeding
# ---------------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 6))
tc = ax.tripcolor(points[:,0], points[:,1], triangles, elevation, cmap='terrain')
plt.colorbar(tc, ax=ax, label='Elevation (m)')
ax.set_title('Original mesh — elevation')
ax.set_aspect('equal')
plt.tight_layout()
plt.show()

# %% -------------------------------------------------------------------------
# 1. Extract ordered boundary polygon from the triangulation
#
# After the MATLAB triangle-trimming step (removing triangles with diameter>20m)
# the mesh boundary may be several disconnected loops. We trace all of them
# and pick the one with the largest enclosed area as the outer boundary.
# ---------------------------------------------------------------------------

# An edge is a boundary edge if it belongs to exactly one triangle
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
    """Walk all closed boundary chains and return as a list of node-index lists."""
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
print(f'Loop areas (m²):       {sorted(loop_areas, reverse=True)}')

# The outer boundary is the loop enclosing the largest area
outer_loop = loops[int(np.argmax(loop_areas))]
bounding_polygon = points[outer_loop].tolist()
print(f'\nOuter boundary: {len(outer_loop)} vertices')
print(f'  x=[{points[outer_loop,0].min():.1f}, {points[outer_loop,0].max():.1f}]')
print(f'  y=[{points[outer_loop,1].min():.1f}, {points[outer_loop,1].max():.1f}]')

# ANUGA requires counterclockwise orientation
if signed_area(bounding_polygon) < 0:
    bounding_polygon = bounding_polygon[::-1]

# %% -------------------------------------------------------------------------
# Visualise boundary polygon — verify it traces the full outer edge
# ---------------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 6))
ax.triplot(points[:,0], points[:,1], triangles, lw=0.3, color='lightgrey')
bp = np.array(bounding_polygon)
ax.plot(np.append(bp[:,0], bp[0,0]), np.append(bp[:,1], bp[0,1]),
        'r-', lw=1.5, label=f'Outer boundary ({len(bounding_polygon)} pts)')
# Plot all other loops in blue so we can see what was discarded
for i, loop in enumerate(loops):
    if loop is not outer_loop:
        lp = points[loop]
        ax.plot(np.append(lp[:,0], lp[0,0]), np.append(lp[:,1], lp[0,1]),
                'b--', lw=0.8, alpha=0.5)
ax.set_title('Boundary loops (red = outer, blue = discarded)')
ax.set_aspect('equal')
ax.legend()
plt.tight_layout()
plt.show()

# %% -------------------------------------------------------------------------
# 2. Build reservoir polygon from convex hull of wet nodes
# ---------------------------------------------------------------------------
reservoir_mask = init_depth > 0
reservoir_pts  = points[reservoir_mask]
print(f'Reservoir nodes: {reservoir_mask.sum()}')
print(f'  x=[{reservoir_pts[:,0].min():.1f}, {reservoir_pts[:,0].max():.1f}]')
print(f'  y=[{reservoir_pts[:,1].min():.1f}, {reservoir_pts[:,1].max():.1f}]')
print(f'  init_depth range: [{init_depth[reservoir_mask].min():.3f}, '
      f'{init_depth[reservoir_mask].max():.3f}] m')

hull = ConvexHull(reservoir_pts)
reservoir_polygon = reservoir_pts[hull.vertices].tolist()
if signed_area(reservoir_polygon) < 0:
    reservoir_polygon = reservoir_polygon[::-1]

# %% -------------------------------------------------------------------------
# Visualise reservoir polygon vs boundary — verify both are in the right place
# ---------------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 6))
ax.triplot(points[:,0], points[:,1], triangles, lw=0.3, color='lightgrey')
bp = np.array(bounding_polygon)
ax.plot(np.append(bp[:,0], bp[0,0]), np.append(bp[:,1], bp[0,1]),
        'r-', lw=1.5, label='Outer boundary')
rp = np.array(reservoir_polygon)
ax.plot(np.append(rp[:,0], rp[0,0]), np.append(rp[:,1], rp[0,1]),
        'b-', lw=1.5, label='Reservoir polygon')
ax.scatter(reservoir_pts[:,0], reservoir_pts[:,1], c='blue', s=10, zorder=5)
ax.set_title('Outer boundary and reservoir polygon')
ax.set_aspect('equal')
ax.legend()
plt.tight_layout()
plt.show()

# %% -------------------------------------------------------------------------
# 3. Create ANUGA domain with refined reservoir region
# ---------------------------------------------------------------------------
max_tri_area       = 150.0   # m²  general resolution (~12m triangles)
reservoir_tri_area = 20.0    # m²  finer inside the reservoir (~4.5m)

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

# %% -------------------------------------------------------------------------
# 4. Set elevation by interpolating from original node data
#
# LinearNDInterpolator gives piecewise-linear interpolation within the
# convex hull of the original data; NearestNDInterpolator is used as a
# fallback for any new mesh vertices that fall just outside that hull.
# ---------------------------------------------------------------------------
interp_linear  = LinearNDInterpolator(points, elevation)
interp_nearest = NearestNDInterpolator(points, elevation)

def elevation_func(x, y):
    z = interp_linear(x, y)
    nan_mask = np.isnan(z)
    if nan_mask.any():
        z[nan_mask] = interp_nearest(x[nan_mask], y[nan_mask])
    return z

domain.set_quantity('elevation', elevation_func)
domain.set_quantity('friction', 0.03)

# %% -------------------------------------------------------------------------
# Visualise new mesh elevation — check it matches the original
# ---------------------------------------------------------------------------
x_c = domain.centroid_coordinates[:, 0]
y_c = domain.centroid_coordinates[:, 1]
elev_c = domain.quantities['elevation'].centroid_values

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Original
tc0 = axes[0].tripcolor(points[:,0], points[:,1], triangles, elevation, cmap='terrain')
plt.colorbar(tc0, ax=axes[0], label='Elevation (m)')
axes[0].set_title('Original mesh elevation')
axes[0].set_aspect('equal')

# New ANUGA mesh
new_tris = domain.get_triangles()
new_verts = domain.get_nodes()
tc1 = axes[1].tripcolor(new_verts[:,0], new_verts[:,1], new_tris, elev_c,
                         cmap='terrain')
plt.colorbar(tc1, ax=axes[1], label='Elevation (m)')
axes[1].set_title('New ANUGA mesh elevation')
axes[1].set_aspect('equal')

plt.tight_layout()
plt.show()

print(f'Elevation range on new mesh: [{elev_c.min():.1f}, {elev_c.max():.1f}] m')
print(f'Elevation range on original: [{elevation.min():.1f}, {elevation.max():.1f}] m')

# %% -------------------------------------------------------------------------
# 5. Set initial stage
#    stage = elevation everywhere (dry bed)
#    stage = elevation + 7.7 inside the reservoir polygon
#
# We read centroid elevation back from the domain (not recompute it) so that
# stage is guaranteed >= stored elevation everywhere.
# ---------------------------------------------------------------------------
res_path = Path(reservoir_polygon + [reservoir_polygon[0]])
in_res   = res_path.contains_points(np.column_stack([x_c, y_c]))

stage_c = elev_c.copy()
stage_c[in_res] += 7.7

print(f'Reservoir triangles with water: {in_res.sum()}')
if in_res.sum() > 0:
    print(f'Stage range in reservoir:  [{stage_c[in_res].min():.2f}, {stage_c[in_res].max():.2f}] m')
    print(f'Elev  range in reservoir:  [{elev_c[in_res].min():.2f},  {elev_c[in_res].max():.2f}] m')
else:
    print('WARNING: no reservoir triangles found — check reservoir polygon vs mesh extent')

domain.set_quantity('stage', stage_c, location='centroids')

# %% -------------------------------------------------------------------------
# 6. Boundary conditions
# ---------------------------------------------------------------------------
Bt = anuga.Transmissive_boundary(domain)
domain.set_boundary({'exterior': Bt})

# %% -------------------------------------------------------------------------
# 7. Run simulation
# ---------------------------------------------------------------------------
yieldstep = 0.5
finaltime = 30.0

print(f'Running: finaltime={finaltime}s, yieldstep={yieldstep}s')
for t in domain.evolve(yieldstep=yieldstep, finaltime=finaltime):
    domain.print_timestepping_statistics()
