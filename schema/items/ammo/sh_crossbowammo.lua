--[[
    NutScript is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NutScript is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with NutScript.  If not, see <http://www.gnu.org/licenses/>.
--]]

ITEM.name = "Crossbow Bolts"
ITEM.model = "models/crossbow_bolt.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
    pos = Vector(-11, 200, 0),
    ang = Angle(0, 270, 0),
    fov = 8
}
ITEM.ammo = "XBowRounds" // type of the ammo
ITEM.ammoAmount = 5 // amount of the ammo
ITEM.ammoDesc = "A Bundle of %s Crossbow Bolts"
ITEM.category = "Ammunition"
ITEM.flag = "y"