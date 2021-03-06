/*
* Copyright (c) 2020 (https://github.com/phase1geo/Outliner)
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

using GLib;

public class ExportMarkdown : Object {

  /* Exports the given drawing area to the file of the given name */
  public static bool export( string fname, OutlineTable table ) {
    var  file   = File.new_for_path( fname );
    bool retval = true;
    try {
      var os = file.create( FileCreateFlags.PRIVATE );
      export_top_nodes( os, table );
    } catch( Error e ) {
      retval = false;
    }
    return( retval );
  }

  /* Draws each of the top-level nodes */
  private static void export_top_nodes( FileOutputStream os, OutlineTable table ) {
    var nodes = table.root.children;
    for( int i=0; i<nodes.length; i++ ) {
      export_node( os, nodes.index( i ), "" );
    }
  }

  public static string from_text( FormattedText text, int start, int end ) {
    FormattedText.ExportStartFunc start_func = (tag, start, extra) => {
      switch( tag ) {
        case FormatTag.BOLD       :  return( "**");
        case FormatTag.ITALICS    :  return( "_" );
        case FormatTag.UNDERLINE  :  return( "__" );
        case FormatTag.STRIKETHRU :  return( "~~" );
        case FormatTag.CODE       :  return( "`" );
        case FormatTag.HEADER     :
          if( start == 0 ) {
            switch( extra ) {
              case "1" :  return( "# " );
              case "2" :  return( "## " );
              case "3" :  return( "### " );
              case "4" :  return( "#### " );
              case "5" :  return( "##### " );
              case "6" :  return( "###### " );
              default  :  return( "" );
            }
          }
          break;
        case FormatTag.URL :  return( "[" );
        default            :  return( "" );
      }
      return( "" );
    };
    FormattedText.ExportEndFunc end_func = (tag, start, extra) => {
      switch( tag ) {
        case FormatTag.BOLD       :  return( "**" );
        case FormatTag.ITALICS    :  return( "_" );
        case FormatTag.UNDERLINE  :  return( "__" );
        case FormatTag.STRIKETHRU :  return( "~~" );
        case FormatTag.CODE       :  return( "`" );
        case FormatTag.URL        :  return( "](%s)".printf( extra ) );
        default                   :  return( "" );
      }
    };
    FormattedText.ExportEncodeFunc encode_func = (str) => {
      return( str.replace( "*", "\\*" ).replace( "_", "\\_" ).replace( "~", "\\~" ).replace( "#", "\\#" ).replace( "`", "\\`" ) );
    };
    return( text.export( start, end, start_func, end_func, encode_func ) );
  }

  /* Draws the given node and its children to the output stream */
  private static void export_node( FileOutputStream os, Node node, string prefix = "  " ) {

    try {

      string title = prefix + "- ";

      /*
      if( node.is_task() ) {
        if( node.is_task_done() ) {
          title += "[x] ";
        } else {
          title += "[ ] ";
        }
      }
      */

      title += from_text( node.name.text, 0, node.name.text.text.char_count() ) + "\n";

      os.write( title.data );

      if( node.note.text.text != "" ) {
        string note = prefix + "  " + from_text( node.note.text, 0, node.note.text.text.char_count() ) + "\n";
        os.write( note.data );
      }

      os.write( "\n".data );

      var children = node.children;
      for( int i=0; i<children.length; i++ ) {
        export_node( os, children.index( i ), prefix + "  " );
      }

    } catch( Error e ) {
      // Handle error
    }

  }

}
