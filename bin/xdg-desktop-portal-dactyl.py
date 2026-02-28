#!/usr/bin/env python3

import asyncio
import json
import subprocess
from dbus_next.aio import MessageBus
from dbus_next.constants import NameFlag
from dbus_next.service import ServiceInterface, method
from dbus_next import Variant, DBusError

class ScreenCastPortal(ServiceInterface):
    def __init__(self):
        super().__init__('org.freedesktop.impl.portal.ScreenCast')
        self.sessions = {}

    async def _get_node_id(self, source_name):
        # Call pw-dump to get PipeWire sources
        try:
            result = subprocess.run(['pw-dump'], capture_output=True, text=True, check=True)
            nodes = json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            raise DBusError('org.freedesktop.portal.Error.Failed', f'Failed to call pw-dump: {e}')
        except json.JSONDecodeError as e:
            raise DBusError('org.freedesktop.portal.Error.Failed', f'Failed to parse pw-dump output: {e}')
        
        # Find the node with the specified name
        for node in nodes:
            if isinstance(node, dict) and node.get('info', {}).get('props', {}).get('node.name') == source_name:
                node_id = node.get('id')
                if node_id is not None:
                    return node_id
        
        raise DBusError('org.freedesktop.portal.Error.NotFound', f'{source_name} source not found')

    @method()
    async def CreateSession(self, handle: 'o', session_handle: 'o', parent_window: 's', options: 'a{sv}') -> 'ua{sv}':
        # Initialize session state
        self.sessions[session_handle] = {"sources": [], "started": False}
        return [0, {}]  # Success

    @method()
    async def SelectSources(self, handle: 'o', session_handle: 'o', parent_window: 's', options: 'a{sv}') -> 'ua{sv}':
        if session_handle not in self.sessions:
            raise DBusError('org.freedesktop.portal.Error.NotFound', 'Session not found')
        
        # Here you would normally show a GUI to select screens/windows
        # For this mock, we just acknowledge the request
        return [0, {}]

    @method()
    async def Start(self, handle: 'o', session_handle: 'o', app_id: 's', parent_window: 's', options: 'a{sv}') -> 'ua{sv}':
        if session_handle not in self.sessions:
            raise DBusError('org.freedesktop.portal.Error.NotFound', 'Session not found')

        # We won't need the session anymore
        del self.sessions[session_handle]

        # This is where we link to the PipeWire "gamescope" source
        node_id = await self._get_node_id('gamescope') 
        
        streams = {
            'streams': Variant('a(ua{sv})', [
                [
                    node_id,
                    {
                        'source_type': Variant('u', 1) # 1: MONITOR, 2: WINDOW, 4: VIRTUAL
                    }
                ]
            ])
        }
        
        return [0, streams]

async def main():
    bus = await MessageBus().connect()
    interface = ScreenCastPortal()
    bus.export('/org/freedesktop/portal/desktop', interface)
    
    # Request the name so the portal-daemon can find this implementation
    await bus.request_name('org.freedesktop.impl.portal.desktop.dactyl', NameFlag.REPLACE_EXISTING)
    
    print("ScreenCast Portal implementation running...")
    await asyncio.get_event_loop().create_future()

if __name__ == '__main__':
    asyncio.run(main())
