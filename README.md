# Simple Progress Bar

![Language](https://img.shields.io/badge/-Fortran-734f96?logo=fortran&logoColor=white)
[![license](https://img.shields.io/badge/License-MIT-pink)](LICENSE)

A simple progress bar module that is typically used to display the time integration process.

## Usage

Only FPM is supported, other build systems can copy source files (`./src/progress_bar.F90`, [`timer/src/timer.F90`][1]) directly.

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

    type(progress_bar) :: bar
    integer :: i

    do i = 1, 10
        call sleep(1)
        call bar%bar(i, 10)
    end do
    print *, ''

    do i = 1, 10
        call sleep(1)
        call bar%bar(i, 10)
        print *, ''
    end do

end program example_progress_bar
!> [***********************] / 10/10 [100%] (1/s, eta: 00:00:00) 
!> [**---------------------] - 1/10 [10%] (-9/s, eta: 00:00:**) 
!> [*****------------------] \ 2/10 [20%] (0/s, eta: 00:00:08) 
!> [*******----------------] | 3/10 [30%] (1/s, eta: 00:00:07) 
!> [*********--------------] / 4/10 [40%] (1/s, eta: 00:00:06) 
!> [************-----------] - 5/10 [50%] (0/s, eta: 00:00:05) 
!> [**************---------] \ 6/10 [60%] (1/s, eta: 00:00:04) 
!> [****************-------] | 7/10 [70%] (1/s, eta: 00:00:03) 
!> [******************-----] / 8/10 [80%] (1/s, eta: 00:00:02) 
!> [*********************--] - 9/10 [90%] (0/s, eta: 00:00:01) 
!> [***********************] \ 10/10 [100%] (1/s, eta: 00:00:00)
```
