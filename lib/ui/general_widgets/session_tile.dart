import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/ui/service_management/update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../styles/styles.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.session});
  final ProductModel session;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        onTap: () {
          // session.description = getDummyDesctiptionByTitle(session.title);
          // session.bundles = getDummyBundleListByFromPrice(session.price);
          session.beforeAfterImageUrl = "https://firebasestorage.googleapis.com/v0/b/aesthetics-lab-1.firebasestorage.app/o/beforeafter.png?alt=media&token=d02661d4-4789-49a7-8a45-fb6050100ed9";
          // Get.to(ServiceDetailsPage(
          //   sessionModel: session,
          // ));
          Get.to(
            UpdateServicePage(productModel: session),
          );
        },
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: session.imageUrl,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 120,
                width: 120,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 120,
                width: 120,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              // width: MediaQuery.of(context).size.width - 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Text(
                            session.title,
                            style: subHeadingFontStyle,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        session.discount != 0.0
                            ?
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          color: Colors.red,
                          child: Text(
                                  "-${session.discount}%",
                            style: bodyFontStyle2,
                          ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  
                  RichText(
                    text: TextSpan(
                      style: bodyFontStyle.copyWith(color: lightGrey),
                      children: <TextSpan>[
                        const TextSpan(text: 'from '),
                        TextSpan(
                          text: 'Rs ${session.price}',
                          style: subHeadingFontStyle.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset('assets/rating.svg'),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/timer.svg'),
                          Text(
                            "${session.duration} mins",
                            style: bodyFontStyle.copyWith(color: lightGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
