String capitalizeName(String string) {
  var names = string.split(' ');
  names[0] = names.elementAt(0).substring(0, 1).toUpperCase() + names.elementAt(0).substring(1).toLowerCase();
  names[1] = names.elementAt(1).substring(0, 1).toUpperCase() + names.elementAt(1).substring(1).toLowerCase();
  return names.join(' ');
}
