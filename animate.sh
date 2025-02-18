ffmpeg -framerate 4 -pattern_type glob -i '*.png'   -c:v libx264 -pix_fmt yuv420p out_4fps.mp4 

