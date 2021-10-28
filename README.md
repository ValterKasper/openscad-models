# OpenSCAD models


| ![preview 1](images/continuous_track.png) | ![preview 1](images/pole_holder.png) | ![preview 1](images/todo.png) |
| --- | --- | --- |
| Continuous tracks, that can be printed in place. | Pole holder | TODO |

## Usage

OpenSCAD has to be on the path.

```sh
make_models.py -f continous_track.scad -e stl   # generates stl file for single piece
make_models.py -l model_list -e png             # renders preview for all models in model_list
```