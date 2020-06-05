#!/usr/bin/env python3



def create_windows(byobu_obj):
    for window_name in byobu_obj.windows:
        create_window(window_name)
