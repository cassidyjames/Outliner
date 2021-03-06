/*
* Copyright (c) 2020 (https://github.com/phase1geo/Minder)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Gtk;

public class LinkEditor : Popover {

  private OutlineTable _ot;
  private bool         _add = true;
  private Entry        _entry;
  private Button       _apply;
  private string       _url_re = "^(mailto:.+@[a-z0-9-]+\\.[a-z0-9.-]+|[a-zA-Z0-9]+://[a-z0-9-]+\\.[a-z0-9.-]+(?:/|(?:/[][a-zA-Z0-9!#$%&'*+,.:;=?@_~-]+)*))$";
  private CanvasText   _text;

  /* Default constructor */
  public LinkEditor( OutlineTable ot ) {

    _ot         = ot;
    relative_to = ot;

    var box   = new Box( Orientation.VERTICAL, 5 );
    box.border_width = 5;

    var ebox  = new Box( Orientation.HORIZONTAL, 5 );
    var lbl   = new Label( _( "URL" ) + ":" );
    _entry = new Entry();
    _entry.width_chars = 50;
    _entry.input_purpose = InputPurpose.URL;
    _entry.activate.connect(() => {
      _apply.activate();
    });
    _entry.changed.connect( check_entry );

    ebox.pack_start( lbl,    false, false );
    ebox.pack_start( _entry, true,  false );

    _apply = new Button.with_label( _( "Apply" ) );
    _apply.get_style_context().add_class( STYLE_CLASS_SUGGESTED_ACTION );
    _apply.clicked.connect(() => {
      set_url();
      show_popover( false );
    });

    var cancel = new Button.with_label( _( "Cancel" ) );
    cancel.clicked.connect(() => {
      _text.clear_selection();
      show_popover( false );
    });

    var bbox = new Box( Orientation.HORIZONTAL, 5 );
    bbox.pack_end( _apply, false, false );
    bbox.pack_end( cancel, false, false );

    box.pack_start( ebox, false, true );
    box.pack_start( bbox, false, true );
    box.show_all();

    add( box );

  }

  /* Shows or hides this popover */
  private void show_popover( bool show ) {

#if GTK322
    if( show ) {
      popup();
    } else {
      popdown();
    }
#else
    if( show ) {
      show();
    } else {
      hide();
    }
#endif
  }

  /*
   Checks the contents of the entry string.  If it is a URL, make the action button active;
   otherwise, inactivate the action button.
  */
  private void check_entry() {
    _apply.set_sensitive( Regex.match_simple( _url_re, _entry.text ) );
  }

  /*
   Sets the URL of the current node's selected text to the value stored in the
   popover entry.
  */
  private void set_url() {
    _text.add_tag( FormatTag.URL, _entry.text, _ot.undo_text );
    _ot.changed();
  }

  /* Called when we want to add a URL to the currently selected text of the given node. */
  public void add_url( CanvasText text ) {

    _text = text;

    int selstart, selend, cursor;
    text.get_cursor_info( out cursor, out selstart, out selend );

    /* Position the popover */
    double left, top;
    text.get_char_pos( selstart, out left, out top );
    Gdk.Rectangle rect = {(int)left, (int)top, 1, 1};
    pointing_to = rect;

    /* Check to see if the selected text is already a valid URL */
    var selected_text = text.get_selected_text();
    var use_selected  = (selected_text != null) && Regex.match_simple( _url_re, selected_text );

    _add        = true;
    _entry.text = use_selected ? selected_text : "";
    _apply.set_sensitive( use_selected );

    show_popover( true );

  }

}
