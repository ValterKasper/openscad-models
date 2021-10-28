OUTPUT_DIR = output

# generate geometry
%.stl: $(SOURCE).scad
	openscad $< -o $@ -P $(PARAMETER_SET) -p $(SOURCE).json
	mkdir -p $(OUTPUT_DIR)
	mv $@ $(OUTPUT_DIR)/$@

# render preview
%.png: $(SOURCE).scad
	openscad $< \
		-o $@ \
		-P $(PARAMETER_SET) \
		-p $(SOURCE).json \
		--render \
		--imgsize=1024,1024 \
		--colorscheme "Tomorrow Night"
	mkdir -p $(OUTPUT_DIR)
	mv $@ $(OUTPUT_DIR)/$@

clear: 
	rm -f $(OUTPUT_DIR)/*.stl
	rm -f $(OUTPUT_DIR)/*.png