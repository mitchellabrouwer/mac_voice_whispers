import Cocoa
import HotKey

func modifierFlags(from commaSeparatedString: String) -> NSEvent.ModifierFlags {
  let array = commaSeparatedString.split(separator: ",")
  var flags = NSEvent.ModifierFlags()

  for modifier in array {
    switch modifier.lowercased() {
    case "control":
      flags.insert(.control)
    case "shift":
      flags.insert(.shift)
    case "option":
      flags.insert(.option)
    case "command":
      flags.insert(.command)
    default:
      continue
    }
  }

  return flags
}

func key(from string: String) -> Key? {
    switch string.lowercased() {
    case "a": return .a
    case "b": return .b
    case "c": return .c
    case "d": return .d
    case "e": return .e
    case "f": return .f
    case "g": return .g
    case "h": return .h
    case "i": return .i
    case "j": return .j
    case "k": return .k
    case "l": return .l
    case "m": return .m
    case "n": return .n
    case "o": return .o
    case "p": return .p
    case "q": return .q
    case "r": return .r
    case "s": return .s
    case "t": return .t
    case "u": return .u
    case "v": return .v
    case "w": return .w
    case "x": return .x
    case "y": return .y
    case "z": return .z
    default: return nil
    }
}
