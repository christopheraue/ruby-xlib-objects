#--
# Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY meh ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL meh OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied.
#++

class Xlib::Capi::XEvent < FFI::Union
	layout \
		:type,              :int,
		:xany,              Xlib::Capi::XAnyEvent,
		:xkey,              Xlib::Capi::XKeyEvent,
		:xbutton,           Xlib::Capi::XButtonEvent,
		:xmotion,           Xlib::Capi::XMotionEvent,
		:xcrossing,         Xlib::Capi::XCrossingEvent,
		:xfocus,            Xlib::Capi::XFocusChangeEvent,
		:xexpose,           Xlib::Capi::XExposeEvent,
		:xgraphicsexpose,   Xlib::Capi::XGraphicsExposeEvent,
		:xnoexpose,         Xlib::Capi::XNoExposeEvent,
		:xvisibility,       Xlib::Capi::XVisibilityEvent,
		:xcreatewindow,     Xlib::Capi::XCreateWindowEvent,
		:xdestroywindow,    Xlib::Capi::XDestroyWindowEvent,
		:xunmap,            Xlib::Capi::XUnmapEvent,
		:xmap,              Xlib::Capi::XMapEvent,
		:xmaprequest,       Xlib::Capi::XMapRequestEvent,
		:xreparent,         Xlib::Capi::XReparentEvent,
		:xconfigure,        Xlib::Capi::XConfigureEvent,
		:xgravity,          Xlib::Capi::XGravityEvent,
		:xresizerequest,    Xlib::Capi::XResizeRequestEvent,
		:xconfigurerequest, Xlib::Capi::XConfigureRequestEvent,
		:xcirculate,        Xlib::Capi::XCirculateEvent,
		:xcirculaterequest, Xlib::Capi::XCirculateRequestEvent,
		:xproperty,         Xlib::Capi::XPropertyEvent,
		:xselectionclear,   Xlib::Capi::XSelectionClearEvent,
		:xselectionrequest, Xlib::Capi::XSelectionRequestEvent,
		:xselection,        Xlib::Capi::XSelectionEvent,
		:xcolormap,         Xlib::Capi::XColormapEvent,
		:xclient,           Xlib::Capi::XClientMessageEvent,
		:xmapping,          Xlib::Capi::XMappingEvent,
		:xerror,            Xlib::Capi::XErrorEvent,
		:xkeymap,           Xlib::Capi::XKeymapEvent,
		:xgeneric,          Xlib::Capi::XGenericEvent,
		:xcookie,           Xlib::Capi::XGenericEventCookie,
		:pad,               [:long, 24]
end

