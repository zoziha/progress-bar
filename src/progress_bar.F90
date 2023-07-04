!> Copyright (c) 2022~2023, ZUO Zhihua. Licensed by MIT.
module progress_bar_module

#ifdef REAL64
    use, intrinsic :: iso_fortran_env, only: rk => real64
#else
    use, intrinsic :: iso_fortran_env, only: rk => real32
#endif
    use, intrinsic :: iso_c_binding, only: CR => c_carriage_return
    use timer_module, only: timer, sec2hms
    implicit none

    private
    public :: progress_bar, CR

    !> Progress bar
    type progress_bar
        private
        integer :: len_bar = 23
        character(1) :: marker(2) = ["*", "-"]
        integer :: count = 1
    contains
        procedure :: init, bar
        procedure, private :: progress, alive
    end type progress_bar

contains

    !> Initialize progress bar
    subroutine init(self, len_bar, marker)
        class(progress_bar), intent(inout) :: self
        integer, intent(in), optional :: len_bar
        character(1), intent(in), optional :: marker(2)

        if (present(len_bar)) self%len_bar = len_bar - 2
        if (present(marker)) self%marker = marker

    end subroutine init

    !> Get a progress bar
    pure function progress(self, p) result(bar)
        class(progress_bar), intent(in) :: self
        real, intent(in) :: p
        character(:), allocatable :: bar
        real :: progress_

        progress_ = min(1.0, max(0.0, p))
        associate (pad => nint(progress_*self%len_bar))
            allocate (bar, source="["//repeat(self%marker(1), pad)// &
                      repeat(self%marker(2), self%len_bar - pad)//"]")
        end associate

    end function progress

    !> Get a alive bar
    function alive(self) result(bar)
        class(progress_bar), intent(inout) :: self
        character(1) :: bar
        character(*), parameter :: marker = "|/-\"

        if (self%count == 5) self%count = 1
        bar(1:1) = marker(self%count:self%count)
        self%count = self%count + 1

    end function alive

    !> Print a progress bar
    !> @note The format control character "\" is an `ifort` extension, the corresponding extension for `gfortran` is "$".
    subroutine bar(self, value, maxval, advance)
        class(progress_bar), intent(inout) :: self
        integer, intent(in) :: value, maxval
        logical, intent(in), optional :: advance
        type(timer), save :: tmr  !! timer
        integer, save :: value_  !! last value
        real(rk) :: dt, v, eta
        logical :: advance_

        if (present(advance)) then
            advance_ = advance
        else
            advance_ = .true.
        end if

        dt = tmr%toc()

        if (maxval == value_) then
            v = 0.0_rk
            eta = 0.0_rk
        else
            v = (value - value_)/dt
            eta = (maxval - value)/v
        end if

        associate (progress => real(value)/maxval)
            value_ = value
            if (advance_) then
#ifdef __INTEL_COMPILER
                write (*, '(2a,1x,a,1x,i0,a,i0,1x,a,i0,a,i0,3a\)') CR, self%progress(progress), &
#else
                    write (*, '(2a,1x,a,1x,i0,a,i0,1x,a,i0,a,i0,3a)', advance='no') CR, self%progress(progress), &
#endif
                    self%alive(), value, '/', maxval, &
                    '[', nint(progress*100), '%] (', nint(v), '/s, eta: ', sec2hms(eta), ')'
            else
                write (*, '(2a,1x,a,1x,i0,a,i0,1x,a,i0,a,i0,3a)') CR, self%progress(progress), &
                    self%alive(), value, '/', maxval, &
                    '[', nint(progress*100), '%] (', nint(v), '/s, eta: ', sec2hms(eta), ')'
            end if
        end associate

        call tmr%tic()

    end subroutine bar

end module progress_bar_module
