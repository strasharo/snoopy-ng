#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import sqlalchemy as sa
from threading import Thread
import time
import includes.system_info as sysinfo
import os
#logging.basicConfig(level=logging.DEBUG)

class Snoop(Thread):
    def __init__(self, **kwargs):
        Thread.__init__(self)
        self.RUN = True
        self.last_heartbeat = 0
        self.heartbeat_freq = 60*30 # Check system every n seconds
        self.drone = kwargs.get('drone',"no_drone_name_supplied")
        self.system_statuses = []

#    def run(self):
#        while self.RUN:
#            time.sleep(2) #Nothing to do here

    def is_ready(self):
        """Indicates the module is ready, and loading of next module may commence."""
        return True

    def stop(self):
        """Perform operations required to stop module and return"""
        self.RUN = False

    @staticmethod
    def get_parameter_list():
        """List of paramters that can be passed to the module, for user help output."""
        return ["None"]

    def get_data(self):
        """Ensure data is returned in the form of a SQL row."""
        tmp_to_return = self.system_statuses 
        self.system_statuses = []
        return tmp_to_return

    def run(self):
        while self.RUN:
            #now = int(time.time())
            now = int(os.times()[4])
            if now > self.last_heartbeat + self.heartbeat_freq:
                logging.debug("Checking system status")
                self.last_heartbeat = now
                global_stats = sysinfo.query_system_status()
                busy_pids = sysinfo.fetch_busy_processes() 
                 
                global_stats['drone'] = self.drone
                global_stats['timestamp'] = int(time.time())
    
                for pid in busy_pids:
                    pid['drone'] = self.drone
                    pid['timestamp'] = now
   
                if global_stats: 
                    self.system_statuses.append( ('sys_global',[global_stats]) )
                if busy_pids:
                    self.system_statuses.append( ('sys_bpids', busy_pids) )
            time.sleep(2)

    @staticmethod
    def get_ident_tables():
        """Return a list of tables that requrie identing - i.e. adding drone name and location"""
        return []

    @staticmethod
    def get_tables():
        """Return the table definitions for this module."""
        # Make sure to define your table here. Ensure you have a 'sunc' column:
        metadata = sa.MetaData()
        table_global = sa.Table('sys_global',metadata,
                              sa.Column('drone', sa.String(length=20), primary_key=True),
                              sa.Column('timestamp', sa.Integer, primary_key=True, autoincrement=False),
                              sa.Column('network_rcvd',sa.Float() ),
                              sa.Column('network_sent',sa.Float() ),
                              sa.Column('uptime',sa.String(15)),
                              sa.Column('used_cpu',sa.Float() ),
                              sa.Column('used_disk',sa.Float() ),
                              sa.Column('used_mem',sa.Float() ),
                              sa.Column('sunc', sa.Integer, default=0))

        table_bpids = sa.Table('sys_bpids',metadata,
                              sa.Column('drone', sa.String(length=20), primary_key=True),
                              sa.Column('timestamp', sa.Integer, primary_key=True, autoincrement=False),
                              sa.Column('cpu',sa.Float() ),
                              sa.Column('mem',sa.Float() ),
                              sa.Column('name',sa.String(length=20) ),
                              sa.Column('pid',sa.Integer ),
                              sa.Column('sunc', sa.Integer, default=0))

        return [table_global,table_bpids]


if __name__ == "__main__":
    Snoop().start()