# OpenSCAD models


| ![Tracs](images/continuous_track.png) | ![Pole holder](images/pole_holder_default.png) | ![Double box](images/assortment_box_box_double.png) |
| --- | --- | --- |
| Continuous tracks, that can be printed in place. | Pole holder | Doublesided assortment box |
| ![Streamer](images/streamer_pcb_holder.png) | ![Streamer](images/streamer_assembly.png) | ![Shower drain](images/shower_drain_default.png) |
| PCB holder of music streamer | Case for a music streamer | Shower drain  |

## Usage

OpenSCAD has to be on the path.

```sh
make_models.py -f continous_track.scad -e stl   # generates stl file for single piece
make_models.py -l model_list -e png             # renders preview for all models in model_list
```