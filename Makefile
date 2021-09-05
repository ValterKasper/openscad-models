OUTPUT_DIR = output

# generate geometry
%.stl: %.scad
	openscad $< -o $@
	mkdir -p $(OUTPUT_DIR)
	mv $@ $(OUTPUT_DIR)/$@

# render preview
%.png: %.scad
	openscad $< \
		-o $@ \
		--render \
		--imgsize=1024,1024 \
		--colorscheme "Tomorrow Night" \

clear: 
	rm -f $(OUTPUT_DIR)/*.stl
	rm -f $(OUTPUT_DIR)/*.png