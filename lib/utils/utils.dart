String nameCaseCorrection(String name) =>
    name.toLowerCase().split(' ').map((name) {
      if (name.isNotEmpty) {
        if (name.length == 1) {
          return name.toUpperCase();
        }
        return '${name[0].toUpperCase()}${name.substring(1)}';
      }
    }).join(' ');
