from threading import Thread
from rplidar import RPLidar
from math import sin, cos, radians, floor
from collections import OrderedDict
import copy
import sys
import os.path
import numpy as np
find_src = lambda p: os.path.sep.join(p[:p.index('src') + 1])
SRC_PATH = find_src(os.path.realpath(__file__).split(os.path.sep))
if SRC_PATH in sys.path:
    pass
else:
    sys.path.insert(0, SRC_PATH)


class LidarStream:
    def __init__(self, port_name='/dev/ttyUSB0'):
        self.port_name = port_name
        self.lidar = None
        # Initialize the object distance and x, y co-ordinates
        self.scans = OrderedDict()
        # initialize the variable used to indicate if the thread should be stopped
        self.stopped = False

    def start(self):
        # initialize the lidar for the stream
        self.lidar = RPLidar(self.port_name)
        self.lidar.connect()
        # start the thread to read frames from the video stream
        Thread(target=self.update, args=()).start()
        return self

    # @timeit
    def update(self):
        # keep looping infinitely until the thread is stopped
        temp_scans = OrderedDict()
        for i, scan in enumerate(self.lidar.iter_measures(max_buf_meas=5000)):
            # print(scan)
            # if the thread indicator variable is set, stop the thread
            if self.stopped:
                self.lidar.stop_motor()
                self.lidar.stop()
                self.lidar.disconnect()
                self.lidar = None
                return
            # otherwise, scan
            angle = floor(scan[2])
            if angle == 359:
                self.scans = copy.deepcopy(temp_scans)
                temp_scans = OrderedDict()

            distance = round(scan[3] / 1000, 2)
            # Calculate the x and y coordinates of the point
            x = distance * np.cos(np.deg2rad(scan[2]))
            y = distance * np.sin(np.deg2rad(scan[2]))
            # x = round(distance * cos(radians(scan[2])))
            # y = round(distance * sin(radians(scan[2])))
            # temp_scans[angle] = {'x': x, 'y': y, 'distance': distance, 'accuracy': scan[1]}
            temp_scans[angle] = (x, y, distance)

    def read(self):
        # return the lidar full scans
        return self.scans

    def stop(self):
        # indicate that the thread should be stopped
        self.stopped = True


if __name__ == "__main__":
    import pprint
    lidarStream = LidarStream()
    lidarStream.start()
    print('Start while loop')
    try:
        while True:
            scans = lidarStream.read()
            print(pprint.pformat(scans))
    except KeyboardInterrupt:
        lidarStream.stop()
    except InterruptedError:
        lidarStream.stop()
    print('Finish while loop')