# Lakes380CoreDepthTools 0.7.0

# Lakes380CoreDepthTools 0.6

* Depths that are now < 1cm below the bottom of the ROI will be assigned the deepest depth within the ROI. If it is more that 1 cm below, an error will still be generated
* Updated the core depth data file, now current as of 7 October 2021


# Lakes380CoreDepthTools 0.5.0

* Added function to account for surface compaction. See `adjustForCompaction` for details.
* Added a function to find core section and core liner depth from dblf. `dblf_to_coreSection`. 

# Lakes380CoreDepthTools 0.4.1

* Fixed bug with hysperspectral data that aren't aligned to zero.

# Lakes380CoreDepthTools 0.4.0

* Updated the core depth data file, now current as of 27 September 2021


# Lakes380CoreDepthTools 0.3.0

* Updated the core depth data file, now current as of 17 September 2021
* Added a `NEWS.md` file to track changes to the package.
