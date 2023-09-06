# Simple Progress Bar

![Language](https://img.shields.io/badge/-Fortran-734f96?logo=fortran&logoColor=white)
[![license](https://img.shields.io/badge/License-MIT-pink)](LICENSE)

A simple progress bar module that is typically used to display the time integration process.

## Usage

Only FPM is supported, other build systems can copy source files (`./src/progress_bar.F90`, [`timer/src/timer.F90`][1]) directly,
and `ifort` and `gfortran` compilers are tested.

To use `progress-bar` within your `fpm` project, add the following lines to your `fpm.toml` file:

```toml
[dependencies]
progress-bar = { git="https://github.com/zoziha/progress-bar" }
```

[1]: https://github.com/zoziha/timer/blob/main/src/timer.F90

## Example

```sh
> fpm run --example --all  # run the example
```

```fortran
program example_progress_bar

    use progress_bar_module, only: progress_bar
    implicit none

    integer :: i

    do i = 1, 10
        call sleep(1)
        call progress_bar(i*100, 500, advance=.false.)
    end do
    call progress_bar(1000, 500, .true.)

    do i = 1, 10
        call sleep(1)
        call progress_bar(i*50, 500, .false.)
    end do
    print *, ""

    do i = 1, 10
        call sleep(1)
        call progress_bar(i*100, 500, .true.)
    end do

end program example_progress_bar
!> [********************] 1000/500 [200%] (0/s, eta: 00:00:00)  
!> [********************] 500/500 [100%] (49/s, eta: 00:00:00) 
!> [****----------------] 100/500 [20%] (0/s, eta: 00:00:00)  
!> [********------------] 200/500 [40%] (98/s, eta: 00:00:03)
!> [************--------] 300/500 [60%] (99/s, eta: 00:00:02)
!> [****************----] 400/500 [80%] (98/s, eta: 00:00:01)
!> [********************] 500/500 [100%] (100/s, eta: 00:00:00)
!> [********************] 600/500 [120%] (98/s, eta: 00:00:00)
!> [********************] 700/500 [140%] (99/s, eta: 00:00:00)
!> [********************] 800/500 [160%] (98/s, eta: 00:00:00)
!> [********************] 900/500 [180%] (98/s, eta: 00:00:00)
!> [********************] 1000/500 [200%] (100/s, eta: 00:00:00)
```

Note: The iterative speed solving aspect is problematic in terms of marginalization details,
but `progess_bar` is sufficient for now.
