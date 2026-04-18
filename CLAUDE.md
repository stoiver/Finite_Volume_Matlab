# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a MATLAB codebase implementing Finite Volume Methods (FVM) for solving conservation laws, with a primary focus on the Shallow Water Equations on unstructured triangular meshes. It supports both fixed-mesh and adaptive mesh refinement/coarsening.

## Running Examples

All code runs from within MATLAB. Add the relevant directories to your MATLAB path first:

```matlab
addpath('FVM', 'ADAPT', 'Examples/Radial_Dam_Refine')  % adjust as needed
```

Run the radial dam-break example (adaptive mesh):
```matlab
[parms, meshT, qT] = radialMain(0.1, 1.0);  % DT=0.1, finalT=1.0
```

Run the linear advection example (fixed mesh):
```matlab
[results, mesh, q] = linearMain(4, 0.05, 'pwl');  % n=4 refinements, dt=0.05
```

## Architecture

### Core Data Structures

**Mesh struct** (created by `fvmMesh` or `fvmSetMeshStruct`):
- `mesh.p` — node coordinates, 2×np
- `mesh.t` — triangle node indices, 3×nt
- `mesh.tneigh` — triangle neighbours, 3×nt (negative values encode boundary type)
- `mesh.normals` — outward edge normals, 2×3×nt
- `mesh.area` — triangle areas, 1×nt
- `mesh.diameters` — inscribed circle diameters, 1×nt (used for CFL timestep control)
- `mesh.elevation_c`, `mesh.friction_c` — per-triangle bed elevation and friction

**Solution array `q`**: nd×nt, where nd is the number of conserved variables. For the shallow water equations: nd=3 (water height h, x-momentum hu, y-momentum hv).

**Parms struct** (created by `fvmSetParmsStruct`): controls which physics functions are called via `feval`. Key fields are function name strings: `edgeFlux`, `boundaryConc`, `riemann`, `phiLimiter`, `phiInterpolator`, `odetype`, `reactionFunct`, `frictionFunct`, `momentumSinkFunct`.

### Directory Structure

- `FVM/` — Core library: mesh construction, flux computation, ODE integration, plotting
- `ADAPT/` — Adaptive mesh drivers and time integrators that also refine/coarsen the mesh
- `Examples/` — Problem-specific setup code, one subdirectory per application

### Execution Flow

**Fixed-mesh problems** use `fvmMain(parms, mesh, qT)`:
1. `fvmLoadMesh(parms)` calls `feval(parms.initialMesh, parms)` to build the initial mesh and solution
2. Time loop calls `feval(parms.odetype, ...)` (e.g., `adaptOdeEuler1`)
3. Each ODE step calls `feval(parms.fluxFunct, ...)` → `fvmGodunovFlux` → per-edge Riemann solver

**Adaptive-mesh problems** use `adaptMain(parms, meshT, qT)`:
1. Same mesh/solution setup as above
2. Time loop calls `adaptOdeRK2` (2nd order) or `adaptOdeEuler1` (1st order)
3. After each sub-step, `adaptRefineCoarsen` refines/coarsens using `bisect`/`coarsen`/`eleminterpolate` from the `ifem` library

### Flux Computation Pipeline

`fvmFluxFunct1` (or similar) → `fvmGodunovFlux`:
1. `fvmPWL1`/`fvmPWL0` — interpolate `q` from cell centres to edge midpoints (piecewise linear or constant)
2. `fvmLimiter` — apply slope limiter to prevent oscillations
3. For each of 3 edges: gather left/right states, call `parms.edgeFlux` → `parms.riemann` (e.g., `swRiemannToro1`)
4. Accumulate flux and divide by cell area

### Adding a New Example

Each example in `Examples/` follows this pattern:
1. A `*Mesh.m` function builds `mesh` and initial `q` (calls `fvmMesh(node, elem)` internally)
2. A `*Main.m` function populates `parms` using `fvmSetParmsStruct`, sets function-pointer fields, and calls `adaptMain` or `fvmMain`
3. The `parms.initialMesh` field is set to the name of the mesh function string so `fvmLoadMesh` can call it via `feval`

### Global Variables

- `FVM_PARAMETERS` — verbosity/printing flags
- `FVM_K` — debug keyboard-interrupt flag (set >0 to drop into `keyboard` mode)
- `ODE_MAXIT` — maximum inner sub-steps before forcing a `keyboard` break

### Shallow Water Equation Functions

The `sw*` functions (not in this repo's `FVM/` directory — expected to be on the MATLAB path separately) implement: `swEdgeFlux`, `swBoundaryConc`, `swRiemannToro1`, `swFlux`, `swFluxFunct1`, `swLimiter0/1`, `swReaction`.

### Mesh Refinement Dependency

`adaptRefineCoarsen` depends on `bisect`, `coarsen`, and `eleminterpolate` from the [iFEM](https://www.math.uci.edu/~chenlong/iFEM.html) library, which must be installed and on the MATLAB path.
