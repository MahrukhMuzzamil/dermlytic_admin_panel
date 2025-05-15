import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/heading_row.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/named_details_row.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BranchTile extends StatelessWidget {
  const BranchTile({super.key, required this.branch});
  final BranchModel branch;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          height: 300,
          width: 300,
          child: CachedNetworkImage(
            imageUrl: branch.branchImage ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'Image not available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const HeadingRow(
          title: "Details",
          width: 290,
        ),
        NamedDetailsRow(
          name: "Branch Name",
          item: branch.branchName,
          isEven: false,
        ),
        if (branch.branchAddress != null)
          NamedDetailsRow(
            name: "Branch Address",
            item: branch.branchAddress!.name,
          ),
        if (branch.branchPhone != null)
          NamedDetailsRow(
            name: "Branch Phone",
            item: branch.branchPhone!,
            isEven: false,
          ),
      ],
    );
  }
}
