!> Copyright (c) 2022~2023, ZUO Zhihua. Licensed by MIT.
module progress_bar_module

#ifdef REAL64
    use, intrinsic :: iso_fortran_env, only: rk => real64
#else
    use, intrinsic :: iso_fortran_env, only: rk => real32
#endif
    use, intrinsic :: iso_c_binding, only: CR => c_carriage_return
    use timer_module, only: clock_timer_type, sec2hms
    implicit none

    private
    public :: progress_bar, CR

    integer, parameter :: maxlen = 132, barlen = 20
    character(1), parameter :: marker(2) = ["*", "-"]

contains

    !> Get a progress bar
    pure function progress(p) result(bar)
        real, intent(in) :: p
        character(:), allocatable :: bar
        real :: progress_

        progress_ = min(1.0, max(0.0, p))
        associate (pad => nint(progress_*barlen))
            allocate (bar, source="["//repeat(marker(1), pad)// &
                      repeat(marker(2), barlen - pad)//"]")
        end associate

    end function progress

    !> Print a progress bar
    !> @note The format control character "\" is an `ifort` extension, the corresponding extension for `gfortran` is "$".
    subroutine progress_bar(value, maxval, advance)
        integer, intent(in) :: value, maxval
        logical, intent(in), optional :: advance
        type(clock_timer_type), save :: tmr  !! timer
        integer, save :: value_ = 0 !! last value
        integer, save :: textlen = 0  !! length of text
        real(rk) :: dt, v, eta
        logical :: advance_
        character(maxlen) :: text

        if (present(advance)) then
            advance_ = advance
        else
            advance_ = .false.
        end if

        dt = tmr%toc()

        if (maxval <= value) then
            eta = 0.0_rk
            if (advance_) then
                if(value_ == value) then
                    v = 0.0_rk
                    value_ = 0
                else
                    v = (value - value_)/dt
                    value_ = value
                end if
            else
                v = (value - value_)/dt
                value_ = value
            end if
        else
            v = (value - value_)/dt
            eta = (maxval - value)/v
            value_ = value
        end if

        v = max(v, 0.0_rk)
        eta = max(eta, 0.0_rk)

        associate (p => real(value)/maxval)

            write (text, '(2a,1x,i0,a,i0,1x,a,i0,a,i0,3a)') CR, progress(p), &
                value, '/', maxval, '[', nint(p*100), '%] (', nint(v), '/s, eta: ', sec2hms(eta), ')'

            if (advance_) then
                write (*, '(2a)') trim(text), repeat(' ', max(textlen - len_trim(text), 0))
                textlen = 0
            else
#ifdef __INTEL_COMPILER
                write (*, '(2a\)') &
#else
                write (*, '(2a)', advance='no') &
#endif
                    trim(text), repeat(' ', max(textlen - len_trim(text), 0))
                textlen = max(len_trim(text), textlen)
            end if

        end associate

        call tmr%tic()

    end subroutine progress_bar

end module progress_bar_module
