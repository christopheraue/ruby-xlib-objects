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

class Xlib::Capi::Struct::XEvent < FFI::Union
	layout \
		:type,              :int,
		:xany,              Xlib::Capi::Struct::XAnyEvent,
		:xkey,              Xlib::Capi::Struct::XKeyEvent,
		:xbutton,           Xlib::Capi::Struct::XButtonEvent,
		:xmotion,           Xlib::Capi::Struct::XMotionEvent,
		:xcrossing,         Xlib::Capi::Struct::XCrossingEvent,
		:xfocus,            Xlib::Capi::Struct::XFocusChangeEvent,
		:xexpose,           Xlib::Capi::Struct::XExposeEvent,
		:xgraphicsexpose,   Xlib::Capi::Struct::XGraphicsExposeEvent,
		:xnoexpose,         Xlib::Capi::Struct::XNoExposeEvent,
		:xvisibility,       Xlib::Capi::Struct::XVisibilityEvent,
		:xcreatewindow,     Xlib::Capi::Struct::XCreateWindowEvent,
		:xdestroywindow,    Xlib::Capi::Struct::XDestroyWindowEvent,
		:xunmap,            Xlib::Capi::Struct::XUnmapEvent,
		:xmap,              Xlib::Capi::Struct::XMapEvent,
		:xmaprequest,       Xlib::Capi::Struct::XMapRequestEvent,
		:xreparent,         Xlib::Capi::Struct::XReparentEvent,
		:xconfigure,        Xlib::Capi::Struct::XConfigureEvent,
		:xgravity,          Xlib::Capi::Struct::XGravityEvent,
		:xresizerequest,    Xlib::Capi::Struct::XResizeRequestEvent,
		:xconfigurerequest, Xlib::Capi::Struct::XConfigureRequestEvent,
		:xcirculate,        Xlib::Capi::Struct::XCirculateEvent,
		:xcirculaterequest, Xlib::Capi::Struct::XCirculateRequestEvent,
		:xproperty,         Xlib::Capi::Struct::XPropertyEvent,
		:xselectionclear,   Xlib::Capi::Struct::XSelectionClearEvent,
		:xselectionrequest, Xlib::Capi::Struct::XSelectionRequestEvent,
		:xselection,        Xlib::Capi::Struct::XSelectionEvent,
		:xcolormap,         Xlib::Capi::Struct::XColormapEvent,
		:xclient,           Xlib::Capi::Struct::XClientMessageEvent,
		:xmapping,          Xlib::Capi::Struct::XMappingEvent,
		:xerror,            Xlib::Capi::Struct::XErrorEvent,
		:xkeymap,           Xlib::Capi::Struct::XKeymapEvent,
		:xgeneric,          Xlib::Capi::Struct::XGenericEvent,
		:xcookie,           Xlib::Capi::Struct::XGenericEventCookie,
		:pad,               [:long, 24]
end

