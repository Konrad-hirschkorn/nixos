import { Gdk } from 'ags/gtk4';
import Bar from './widgets/Bar';
import Overview from './widgets/Overview';

// Manager component — places Bar first (reserves bottom edge) then Overview
export default function Manager(gdkmonitor: Gdk.Monitor) {
  Bar(gdkmonitor); // bottom, EXCLUSIVE
  Overview(gdkmonitor); // fills the rest, SHARED
}
