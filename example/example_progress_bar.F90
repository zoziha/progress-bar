program example_progress_bar

    use progress_bar_module, only: progress_bar
    implicit none

    type(progress_bar) :: bar
    integer :: i

    do i = 1, 10
        call sleep(1)
        call bar%bar(i, 10, advance=.true.)
    end do
    call bar%bar(10, 10, .false.)

    do i = 1, 10
        call sleep(1)
        call bar%bar(i, 10, .false.)
    end do

end program example_progress_bar
