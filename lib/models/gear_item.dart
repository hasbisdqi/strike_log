class GearItem {
  final String id;
  final String name;
  final String category; // 'Reel', 'Rod', 'Lure', 'Line'
  final String brand;
  final String spec;
  final bool isCustom;

  const GearItem({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.spec,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'brand': brand,
        'spec': spec,
        'is_custom': isCustom,
      };

  factory GearItem.fromJson(Map<String, dynamic> json) => GearItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        brand: json['brand'] as String? ?? 'General',
        spec: json['spec'] as String? ?? '',
        isCustom: json['is_custom'] as bool? ?? false,
      );
}

class MasterGearCatalog {
  static const List<GearItem> allItems = [
    // --- REEL ---
    GearItem(
      id: 'reel_shimano_stradic',
      name: 'Shimano Stradic FL 3000',
      category: 'Reel',
      brand: 'Shimano',
      spec: 'Hagane Gear, X-Protect, Ratio 6.0:1',
    ),
    GearItem(
      id: 'reel_shimano_stella',
      name: 'Shimano Stella SW 4000HG',
      category: 'Reel',
      brand: 'Shimano',
      spec: 'Infinity Drive, Max Drag 11kg, Saltwater',
    ),
    GearItem(
      id: 'reel_daiwa_bg',
      name: 'Daiwa BG 4000',
      category: 'Reel',
      brand: 'Daiwa',
      spec: 'Hardbodyz Anodized, ATD Drag 8kg',
    ),
    GearItem(
      id: 'reel_daiwa_revros',
      name: 'Daiwa Revros LT 2500',
      category: 'Reel',
      brand: 'Daiwa',
      spec: 'Light & Tough, Air Rotor, 4+1 BB',
    ),
    GearItem(
      id: 'reel_ryobi_zeus',
      name: 'Ryobi Zeus HP 3000',
      category: 'Reel',
      brand: 'Ryobi',
      spec: 'Aluminium Spool, Power Handle, Drag 7kg',
    ),
    GearItem(
      id: 'reel_penn_battle',
      name: 'Penn Battle III 5000',
      category: 'Reel',
      brand: 'Penn',
      spec: 'Full Metal Body, HT-100 Carbon Drag 11.3kg',
    ),

    // --- ROD / JORAN ---
    GearItem(
      id: 'rod_relix_cangkek',
      name: 'Relix Nusantara Cangkek 682 UL',
      category: 'Rod',
      brand: 'Relix Nusantara',
      spec: 'Panjang 6\'8", Lure 1-8gr, Ring Sea Guide',
    ),
    GearItem(
      id: 'rod_relix_sisik',
      name: 'Relix Nusantara Sisik 702',
      category: 'Rod',
      brand: 'Relix Nusantara',
      spec: 'Panjang 7\'0", Line 8-17lb, Medium Fast',
    ),
    GearItem(
      id: 'rod_shimano_bassterra',
      name: 'Shimano Bassterra EV',
      category: 'Rod',
      brand: 'Shimano',
      spec: 'Diaflash Carbon, Lure 7-28gr, Fuji O-Ring',
    ),
    GearItem(
      id: 'rod_daiwa_phantom',
      name: 'Daiwa Phantom Snapper',
      category: 'Rod',
      brand: 'Daiwa',
      spec: 'Braiding X Carbon, Line 10-25lb, Karang & Muara',
    ),
    GearItem(
      id: 'rod_maguro_extreme',
      name: 'Maguro Extreme Cast 180',
      category: 'Rod',
      brand: 'Maguro',
      spec: 'High Carbon Compound, Action Medium Heavy',
    ),

    // --- LURE / UMPAN ---
    GearItem(
      id: 'lure_rapala_xrap',
      name: 'Rapala X-Rap Saltwater 10cm',
      category: 'Lure',
      brand: 'Rapala',
      spec: 'Slashbait Action, Kedalaman 1.2-1.8m, Cast/Troll',
    ),
    GearItem(
      id: 'lure_soft_frog',
      name: 'Soft Frog Kodok Karet 4cm',
      category: 'Lure',
      brand: 'Custom Lure',
      spec: 'Double Hook Shield, Topwater, Gabus & Toman',
    ),
    GearItem(
      id: 'lure_metal_jig',
      name: 'Micro Metal Jig 20g Gid Zebra',
      category: 'Lure',
      brand: 'CastJig',
      spec: 'Glow In Dark, Fast Flutter Action, Muara & Karang',
    ),
    GearItem(
      id: 'lure_minnow_sinking',
      name: 'Minnow Sinking 7cm 8g',
      category: 'Lure',
      brand: 'Lure Specialist',
      spec: 'Tight Wobbling, Kedalaman 0.8-1.5m, Predator Muara',
    ),
    GearItem(
      id: 'lure_popper_surface',
      name: 'Popper Surface Chugger 9cm',
      category: 'Lure',
      brand: 'River2Sea',
      spec: 'Loud Splash & Pop, Ikan Pelagis & GT',
    ),
    GearItem(
      id: 'lure_live_shrimp',
      name: 'Umpan Alami: Udang Hidup',
      category: 'Lure',
      brand: 'Live Bait',
      spec: 'Kail Punggung/Ekor, Kakap & Kerapu',
    ),

    // --- LINE / SENAR ---
    GearItem(
      id: 'line_duraking_natuna',
      name: 'PE Duraking Natuna X8 (PE 1.5)',
      category: 'Line',
      brand: 'Duraking',
      spec: '8 Braided, Max 24lb, Multicolor 100m',
    ),
    GearItem(
      id: 'line_shimano_kairiki',
      name: 'PE Shimano Kairiki 8 (PE 2.0)',
      category: 'Line',
      brand: 'Shimano',
      spec: 'VT Construction, Halus & Senyap, 300m',
    ),
    GearItem(
      id: 'line_relix_samar',
      name: 'Leader Relix Samar Fluorocarbon (25lb)',
      category: 'Line',
      brand: 'Relix Nusantara',
      spec: '100% Fluorocarbon, Indeks Bias Mirip Air, Anti Gesek',
    ),
  ];
}
