# POVERTY DATA
# download the zip: 
builds/development/js/json/poverty/gz_2010_us_050_00_20m.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2010/$(notdir $@)

# unzips it: 
builds/development/js/json/poverty/gz_2010_us_050_00_20m.shp: builds/development/js/json/poverty/gz_2010_us_050_00_20m.zip
	unzip -od $(dir $@) $<
	touch $@

# make the boundaries
builds/development/js/json/poverty/counties.json: builds/development/js/json/poverty/gz_2010_us_050_00_20m.shp
	node_modules/.bin/topojson \
		-o $@ \
		--projection='width = 960, height = 600, d3.geo.albersUsa() \
			.scale(1280) \
			.translate([width / 2, height / 2])' \
		--simplify=.5 \
		-- counties=$<


# Map the data to land
builds/development/js/json/poverty/counties.json: builds/development/js/json/poverty/gz_2010_us_050_00_20m.shp builds/development/js/json/poverty/ACS_14_1YR_S1701_with_ann.csv
	node_modules/.bin/topojson \
		-o $@ \
		--id-property='STATE+COUNTY,Id2' \
		--external-properties=builds/development/js/json/poverty/ACS_14_1YR_S1701_with_ann.csv \
		--properties='name=Geography' \
		--properties='population=+d.properties["Below poverty level; Estimate; AGE - Under 18 years"]' \
		--projection='width = 960, height = 600, d3.geo.albersUsa() \
			.scale(1280) \
			.translate([width / 2, height / 2])' \
		--simplify=.5 \
		-- counties=$<

#Display state instead of county boundaries
builds/development/js/json/poverty/states.json: builds/development/js/json/poverty/counties.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=counties \
		--out-object=states \
		--key='d.id.substring(0, 2)' \
		-- $<

#Display national boundary
builds/development/js/json/poverty/us.json: builds/development/js/json/poverty/states.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=states \
		--out-object=nation \
		-- $<



