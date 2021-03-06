# Lakes380CoreDepthTools 0.13.0

* Updated the core depth data file, now current as of 6 July 2022

# Lakes380CoreDepthTools 0.12.1

* Updated the core depth data file, now current as of 5 July 2022

# Lakes380CoreDepthTools 0.12.0

* Updated the core depth data file, now current as of 10 May 2022

# Lakes380CoreDepthTools 0.11.2

* Updated the core depth data file, now current as of 21 April 2022

# Lakes380CoreDepthTools 0.11.1

* Updated the core depth data file, now current as of 29 March 2022

# Lakes380CoreDepthTools 0.11.0

* Updated the core depth data file, now current as of 16 February 2022

# Lakes380CoreDepthTools 0.10.0

* Updated the core depth data file, now current as of 10 February 2022

# Lakes380CoreDepthTools 0.9.0

* Updated the core depth data file, now current as of 29 November 2021

# Lakes380CoreDepthTools 0.8.0

* `dblf_from_file()` now works for HSI too. 
* readme updated

# Lakes380CoreDepthTools 0.7.2

* Updated the core depth data file, now current as of 4 November 2021
* HSI depths now allow depths that are now < 1cm below the bottom of the ROI will be assigned the deepest depth within the ROI. If it is more that 1 cm below, an error will still be generated.

# Lakes380CoreDepthTools 0.7.1

* Added functionality to convert HSI depths


# Lakes380CoreDepthTools 0.7.0

* Updated the core depth data file, now current as of 15 October 2021
* Depths that are now < 1cm below the bottom of the ROI will be assigned the deepest depth within the ROI. If it is more that 1 cm below, an error will still be generated

# Lakes380CoreDepthTools 0.6.0

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
