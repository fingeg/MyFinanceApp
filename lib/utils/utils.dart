String nameCaseCorrection(String name) =>
    name.trim().toLowerCase().split(' ').map((name) {
      if (name.isNotEmpty) {
        if (name.length == 1) {
          return name.toUpperCase();
        }
        return '${name[0].toUpperCase()}${name.substring(1)}';
      }
    }).join(' ');
