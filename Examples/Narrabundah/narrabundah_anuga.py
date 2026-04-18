"""
narrabundah_anuga.py

ANUGA shallow water simulation of the Narrabundah reservoir,
using the mesh exported from narrabundahMesh.m via exportNarrabundahMesh.m.

Run the Octave export first:
    octave-cli --no-line-editing exportNarrabundahMesh.m

Then run this script:
    python narrabundah_anuga.py
"""

import numpy as np
import anuga
from collections import defaultdict

# ---------------------------------------------------------------------------
# Load mesh data exported from Octave
# ---------------------------------------------------------------------------
nodes = np.loadtxt('narrabundah_nodes.csv', delimiter=',')
triangles = np.loadtxt('narrabundah_triangles.csv', delimiter=',', dtype=int)

points    = nodes[:, 0:2]   # (np, 2)  x, y coordinates
elevation = nodes[:, 2]     # (np,)    bed elevation (m)
friction  = nodes[:, 3]     # (np,)    Manning's n
init_depth = nodes[:, 4]    # (np,)    initial water depth (m)

np_nodes = points.shape[0]
nt = triangles.shape[0]
print(f'Mesh: {np_nodes} nodes, {nt} triangles')

# ---------------------------------------------------------------------------
# Detect boundary edges and tag them all as 'exterior'
# An edge is a boundary edge if it belongs to only one triangle.
# ---------------------------------------------------------------------------
edge_to_tri = defaultdict(list)
for tri_idx, tri in enumerate(triangles):
    for local_edge in range(3):
        n0 = tri[local_edge]
        n1 = tri[(local_edge + 1) % 3]
        edge = (min(n0, n1), max(n0, n1))
        edge_to_tri[edge].append((tri_idx, local_edge))

boundary = {}
for edge, tris in edge_to_tri.items():
    if len(tris) == 1:
        tri_idx, local_edge = tris[0]
        boundary[(tri_idx, local_edge)] = 'exterior'

print(f'Boundary edges: {len(boundary)}')

# ---------------------------------------------------------------------------
# Create ANUGA domain
# ---------------------------------------------------------------------------
domain = anuga.Domain(points, triangles, boundary)
domain.set_name('narrabundah')
domain.set_datadir('.')

# Second-order spatial reconstruction (matches MATLAB pwl scheme)
domain.set_default_order(2)

# ---------------------------------------------------------------------------
# Set quantities
# ---------------------------------------------------------------------------
domain.set_quantity('elevation', elevation, location='vertices')
domain.set_quantity('friction',  friction,  location='vertices')

# Initial stage = bed elevation + water depth
init_stage = elevation + init_depth
domain.set_quantity('stage', init_stage, location='vertices')

# ---------------------------------------------------------------------------
# Boundary conditions — transmissive (open) on all exterior edges,
# matching the MATLAB narrabundah0.m setup (all tneigh=-1)
# ---------------------------------------------------------------------------
Bt = anuga.Transmissive_boundary(domain)
domain.set_boundary({'exterior': Bt})

# ---------------------------------------------------------------------------
# Run simulation
# ---------------------------------------------------------------------------
yieldstep = 0.5   # output interval (s)
finaltime  = 30.0  # total simulation time (s)

print(f'\nRunning simulation: finaltime={finaltime}s, yieldstep={yieldstep}s')
for t in domain.evolve(yieldstep=yieldstep, finaltime=finaltime):
    domain.print_timestepping_statistics()
