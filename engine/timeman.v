module engine

import math

pub struct TimeControl {
pub mut:
	time_remaining [3]int = [3]int{init: 5000}
	increments     [3]int = [3]int{init: 0}
}

fn TimeControl.parse(mut args []string) TimeControl {
	mut tc := TimeControl{}

	for arg in args {
		match arg {
			'wtime' {
				index := args.index('wtime') + 1
				if args[index].is_int() {
					tc.time_remaining[1] = args[index].int()
				}
			}
			'winc' {
				index := args.index('winc') + 1
				if args[index].is_int() {
					tc.increments[1] = args[index].int()
				}
			}
			'btime' {
				index := args.index('btime') + 1
				if args[index].is_int() {
					tc.time_remaining[2] = args[index].int()
				}
			}
			'binc' {
				index := args.index('binc') + 1
				if args[index].is_int() {
					tc.increments[2] = args[index].int()
				}
			}
			else {}
		}
	}

	return tc
}

pub fn (bot Engine) choose_time_limit(time_control TimeControl) int {
	us := bot.board.turn

	my_time_remaining := time_control.time_remaining[us]
	my_time_increment := time_control.increments[us]
	min_think_time := math.min(25, my_time_remaining / 4)

	mut time_limit := my_time_remaining / 10

	if my_time_remaining > my_time_increment * 2 {
		time_limit += my_time_increment * 80 / 100
	}

	return math.max(min_think_time, time_limit)
}
