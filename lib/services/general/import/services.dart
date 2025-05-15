import 'dart:io';
import 'dart:typed_data';
import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/services/product_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

void addMultipleProducts() async {
  const imageUrl = 'https://firebasestorage.googleapis.com/v0/b/aesthetics-lab.appspot.com/o/branches%2F1714733630961?alt=media';
  const double price = 10000;
  const double duration = 45;

  List<String> productTitles = [
    "Laser for mole removal",
    "Photo Facial",
    "Q Switch Half Back",
    "Belly Q Switch",
    "Peco laser - Underlegs",
    "Laser for skin tag removal",
    "Peco Laser (Half Back)",
    "Cautery",
    "Q Switch for Underarms",
    "Thigh RF Fractional",
    "Peco Laser (Lips)",
    "Q-Switch for Lips",
    "Laser for birth mark removal",
    "Peco Laser",
    "Peco laser - Hipline",
    "Laser for tattoo removal",
    "Laser hair removal for cheeks",
    "Half Body Laser Hair Removal Men",
    "Laser hair removal for back",
    "Laser Hair Removal for Legs - Candela",
    "Laser Hair Removal for Ear and Forehead",
    "Laser Hair Removal for Back - Candela",
    "Laser Hair Removal for Chest - Candela",
    "Laser Hair Removal for Ears - Candela",
    "Laser for Chest Hair Removal",
    "Laser hair removal for neck",
    "Laser hair removal chest and Abdomen",
    "Laser hair removal for shoulders",
    "Laser Hair Removal for Arms- Candela",
    "Laser hair removal for full body Men",
    "Laser Hair Removal for Beard Contouring ( Cheeks & Neck) - Candela",
    "Laser hair removal for arms Men",
    "Laser Hair Removal for Neck - Candela",
    "Laser Hair Removal for Hip",
    "Laser hair removal for legs Men",
    "Beard Contouring Cheeks Only",
    "Laser Hair Removal for Chest and Abdomen - Candela",
    "Laser Hair Removal for shoulders - Candela",
    "Half Arms Laser",
    "Laser Hair Removal for Cheeks - Candela",
    "Laser hair removal for beard contouring cheeks Or neck",
    "Back and Hip Laser Hair Removal",
    "Laser Hair Removal for Underarms (Men)",
    "Carbon Peel (Full Arms+Hands)",
    "Chemical Peel (Feet)",
    "Biorey Peel/ml",
    "Chemical Peel for Underarms",
    "Carbon Peel (Feet)",
    "Chemical Peel (Back)",
    "Chemical Peel",
    "Chemical Peel (Face+ Neck)",
    "Chemical Peel (Hands)",
    "Carbon Peel (Lips)",
    "Carbon Peel (Hands)",
    "Carbon Peeling",
    "Carbon Peel (Hands + Feet)",
    "Carbon Peel (Underarms)",
    "Chemical Peel (Hands + Feet)",
    "Chemical Peel for Full Body",
    "Carbon Peel (Neck)",
    "Chemical Peel (Arms)",
    "Carbon Peel (Half Arms+Hands)",
    "Chemical Peel (Neck)",
    "Chemical Peel for Legs",
    "Chemical Peel for Elbows",
    "Chemical Peel for Knees",
    "Chemical Peel (Underlegs)",
    "Women's Day Hydra Facial",
    "Hydra Facial including neck",
    "Black Heads Removal",
    "Deep Cleansing - HydraFacial",
    "Hydra Facial for full back includig hips",
    "Test Facial",
    "Hydra Facial with glow mask",
    "Gift Hydra Facial - Mother s Day",
    "Deep Cleansing with neck - HydraFacial",
    "PRP serum",
    "Follow-up Treatment",
    "PRP therapy for face+neck rejuvenation",
    "PRP Hair with Exosomes",
    "PRP for Hair fall with meso serums",
    "PRP for Hair fall",
    "PRP face (Serums + Plasma)",
    "PRP therapy for face rejuvenation",
    "Under Eye PRP with Microneedling",
    "Under Eye PRP",
    "Laser hair removal for face - Candela",
    "Laser hair removal for full body",
    "Laser hair removal for Under Legs - Candela",
    "Laser hair removal for sides - Candela",
    "Laser hair removal for under legs and under arms",
    "Laser for Under Legs",
    "Laser for Half Arms",
    "Laser hair removal for Arms - Candela",
    "Laser for Foot",
    "Laser hair removal for Feet - Candela",
    "Laser for underarms hair removal",
    "Laser hair removal for sides",
    "Hip Laser Hair Removal",
    "Laser for chest",
    "Laser Hair removal for Full Body - Candela",
    "Laser hair removal for upper lip and chin - Candela",
    "Laser for Half Legs",
    "Candela - Nose Laser Hair Removal",
    "Laser Hair Removal For Face and Neck",
    "Laser Hair Removal for Abdomen",
    "Laser Hair Removal for Upper lip and Chin",
    "Laser hair removal for upperlip",
    "Laser Hair Removal for Back Women",
    "Laser for full neck hair removal (front/back)",
    "Laser hair removal for lower face",
    "Half Arms Laser Hair Removal - Candela",
    "Laser hair removal for Under Legs and Under Arms- Candela",
    "Laser Hair Removal for Face (Candela)",
    "Laser hair removal for Full Legs - Candela",
    "Candela - Abdomen Laser Hair Removal",
    "Half Lower Body Laser (Women)",
    "Laser hair removal for arms",
    "Laser hair removal for Half Legs - Candela",
    "Laser hair removal for chin",
    "Laser hair removal for legs",
    "Laser hair removal for chin - Candela",
    "Laser hair removal for lower face - Candela",
    "Laser hair removal for upper lip - Candela",
    "Laser hair removal for Under Arms - Candela",
    "Half Body Laser - Candela",
    "Laser for facial hair removal",
    "Half Upper Body Laser (Women)",
    "Laser Hair Removal for Half Back - Candela",
    "Skin Tightening Treatment",
    "Botox (Underarms)",
    "Face HIFU",
    "Tricep HIFU",
    "Q-Switch therapy",
    "Glow Drip (Swiss)",
    "Face Exosomes Therapy",
    "Fat Grafting",
    "K Kart",
    "Corn Removal",
    "Keloid",
    "RF Fractional",
    "Ellanse Filler",
    "Double Chin HIFU",
    "Botox-USA/Unit",
    "Maili Soft",
    "Lypolytic Injection/ml",
    "Weight Reduction (following month)",
    "Hands and Feet Knucles Carbon Peel",
    "Maili Basic",
    "Microneedling (Serums + Plasma)",
    "Inj Venofer",
    "Subsicion",
    "Botox (Upper Face)",
    "Glow Drip (Korean)",
    "RF Microneedling with Plasma",
    "Toe Nail Treatment",
    "BB Glow",
    "Korean Slimming Drips/ml",
    "Micro needling with serum",
    "Skin Booster Belgium - Profhilo",
    "Ozempic Dose",
    "Nucleofill Under Eye",
    "Weight Reduction (1st month)",
    "Mehndi",
    "PCL Thread (Pair)",
    "Neurobion Inj",
    "Ellanse Soft/ml",
    "Deep Fillers (Long)/ml",
    "Skin Booster Korean - Hyamira",
    "Ellanse Basicml",
    "Restylane Filler",
    "Complaint Service",
    "Soft Fillers",
    "Inj Multibionta",
    "Comedone Extraction",
    "Light Therapy",
    "Neck HIFU",
    "PDO Thread",
    "Electrolysis/10 Hair",
    "Mesotheray",
    "Deep Fillers",
    "Skin rejuvenation therapy"
  ];

  for (String title in productTitles) {
    ProductModel product = ProductModel(
      title: title,
      imageUrl: imageUrl,
      price: price,
      duration: duration,
    );
    ProductService productService = ProductService();
    bool isSuccess = await productService.addProduct(product);
    if (isSuccess) {
      print('Product $title added successfully');
    } else {
      print('Failed to add product $title');
    }
  }
}

Future<void> readExcelAndAddProducts(String filePath) async {
  // Load the Excel file
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  const imageUrl = 'https://firebasestorage.googleapis.com/v0/b/aesthetics-lab.appspot.com/o/branches%2F1714733630961?alt=media';

  for (var table in excel.tables.keys) {
    if (excel.tables[table] != null) {
      for (var row in excel.tables[table]!.rows) {
        if (row[0] != null && row[1] != null && row[2] != null) {
          String title = row[0]!.value.toString();
          double duration = double.tryParse(row[1]!.value.toString()) ?? 0.0;
          double price = double.tryParse(row[2]!.value.toString()) ?? 0.0;

          ProductModel product = ProductModel(
            title: title,
            imageUrl: imageUrl,
            price: price,
            duration: duration,
          );
          ProductService productService = ProductService();

          bool isSuccess = await productService.addProduct(product);
          if (isSuccess) {
            print('Product $title added successfully');
          } else {
            print('Failed to add product $title');
          }
        }
      }
    }
  }
}

Future<void> readExcelFromAssets() async {
  const imageUrl = 'https://firebasestorage.googleapis.com/v0/b/aesthetics-lab.appspot.com/o/branches%2F1714733630961?alt=media';

  // Load the Excel file from assets
  ByteData data = await rootBundle.load('assets/ServiceData.xlsx');
  List<int> bytes = data.buffer.asUint8List();

  // Decode the Excel file
  var excel = Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    if (excel.tables[table] != null) {
      for (var row in excel.tables[table]!.rows) {
        if (row[0] != null && row[1] != null && row[2] != null) {
          String title = row[0]!.value.toString();
          double duration = double.tryParse(row[1]!.value.toString()) ?? 0.0;
          double price = double.tryParse(row[2]!.value.toString()) ?? 0.0;
          // Enforce a minimum duration of 15 minutes
          if (duration < 15.0) {
            duration = 15.0;
          }

          ProductModel product = ProductModel(
            title: title,
            imageUrl: imageUrl,
            price: price,
            duration: duration,
          );
          ProductService productService = ProductService();
          bool isSuccess = await productService.addProduct(product);
          if (isSuccess) {
            print('Product $title added successfully');
          } else {
            print('Failed to add product $title');
          }
        }
      }
    }
  }
}
