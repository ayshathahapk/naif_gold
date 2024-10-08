import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as Math;
import '../../../Core/app_export.dart';
import '../Controller/live_controller.dart';

class CommodityList extends ConsumerWidget {
  final double price;
  const CommodityList({
    super.key,
    required this.price,
  });
  double getUnitMultiplier(String weight) {
    switch (weight) {
      case "GM":
        return 1;
      case "KG":
        return 1000;
      case "TTB":
        return 116.6400;
      case "TOLA":
        return 11.664;
      case "OZ":
        return 31.1034768;
      default:
        return 1;
    }
  }

  String dToInt({required double value}) {
    String formattedValue =
        value % 1 == 0 ? value.toInt().toString() : value.toString();
    return formattedValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(spotRateProvider).when(
          data: (data) {
            if (data != null) {
              final commodity = data.info.commodities;
              return Column(
                children: [
                  Container(
                    width: SizeUtils.width,
                    height: SizeUtils.height * 0.07,
                    decoration: BoxDecoration(
                      color: const Color(0xFF045147),
                      // Color(0xFF023930)
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.v),
                          topRight: Radius.circular(15.v)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "COMMODITY",
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                              Text(
                                "سلعة",
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 90.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "UNIT",
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                              Text(
                                "وحدة",
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 120.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SELL",
                                textAlign: TextAlign.center,
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                              Text(
                                "يبيع",
                                textAlign: TextAlign.center,
                                style: CustomPoppinsTextStyles.bodyText1Gold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (context, ref2, child) {
                      // print("Consumer is rebulding");

                      return Container(
                          height: SizeUtils.height * 0.22,
                          child: ListView.builder(
                            itemCount: commodity.length,
                            itemBuilder: (context, index) {
                              // print(commodity[index].toMap());
                              final commodities = commodity[index];
                              if (commodities.metal == "Gold") {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0.v,
                                  ),
                                  child: Container(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.05,
                                    decoration: const BoxDecoration(
                                      // border: Border.all(),
                                      color: Color(0xFF023930),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 180.h,
                                          child: Center(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      "${commodities.metal.toUpperCase()} ",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1),
                                              TextSpan(
                                                  text: commodities.purity
                                                      .toString(),
                                                  style: GoogleFonts.poppins(
                                                      // fontFamily: marine,
                                                      color: appTheme.whiteA700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15.fSize))
                                            ])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90.h,
                                          child: Center(
                                            child: Text(
                                              dToInt(value: commodities.unit) +
                                                  commodities.weight,
                                              style: CustomPoppinsTextStyles
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                        Consumer(
                                          builder: (context, refSell, child) {
                                            final cat =
                                                price + commodities.sellPremium;
                                            final askNow =
                                                (cat / 31.103) * 3.674;
                                            final rateNow = askNow *
                                                    (commodities.unit *
                                                        getUnitMultiplier(
                                                            commodities
                                                                .weight)) *
                                                    (commodities.purity /
                                                        Math.pow(
                                                            10,
                                                            (commodities.purity
                                                                    .toString())
                                                                .length)) +
                                                commodities.sellCharge;
                                            return SizedBox(
                                              width: 120.h,
                                              child: Center(
                                                child: Text(
                                                  rateNow.toStringAsFixed(2),
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (commodities.weight == "KG") {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0.v,
                                  ),
                                  child: Container(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.05,
                                    decoration: const BoxDecoration(
                                      // border: Border.all(),
                                      color: Color(0xFF023930),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 180.h,
                                          child: Center(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text: "GOLD ",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1),
                                              TextSpan(
                                                  text: commodities.purity
                                                      .toString(),
                                                  style: GoogleFonts.poppins(
                                                      // fontFamily: marine,
                                                      color: appTheme.mainWhite,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15.fSize))
                                            ])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90.h,
                                          child: Center(
                                            child: Text(
                                              dToInt(value: commodities.unit) +
                                                  commodities.weight,
                                              style: CustomPoppinsTextStyles
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                        Consumer(
                                          builder: (context, refSell, child) {
                                            final cat =
                                                price + commodities.sellPremium;
                                            final askNow =
                                                (cat / 31.103) * 3.674;
                                            final rateNow = askNow *
                                                    (commodities.unit *
                                                        getUnitMultiplier(
                                                            commodities
                                                                .weight)) *
                                                    (commodities.purity /
                                                        Math.pow(
                                                            10,
                                                            (commodities.purity
                                                                    .toString())
                                                                .length)) +
                                                commodities.sellCharge;
                                            return SizedBox(
                                              width: 120.h,
                                              child: Center(
                                                child: Text(
                                                  rateNow.toStringAsFixed(2),
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (commodities.weight == "TTB") {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0.v,
                                  ),
                                  child: Container(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.05,
                                    decoration: const BoxDecoration(
                                      // border: Border.all(),
                                      color: Color(0xFF023930),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 180.h,
                                          child: Center(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text: "GOLD",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1),
                                              TextSpan(
                                                  text: "TENTOLA",
                                                  style: GoogleFonts.poppins(
                                                      // fontFamily: marine,
                                                      color: appTheme.whiteA700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15.fSize))
                                            ])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90.h,
                                          child: Center(
                                            child: Text(
                                              dToInt(value: commodities.unit) +
                                                  commodities.weight,
                                              style: CustomPoppinsTextStyles
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                        Consumer(
                                          builder: (context, refSell, child) {
                                            final cat =
                                                price + commodities.sellPremium;
                                            final askNow =
                                                (cat / 31.103) * 3.674;
                                            final rateNow = askNow *
                                                    (commodities.unit *
                                                        getUnitMultiplier(
                                                            commodities
                                                                .weight)) *
                                                    (commodities.purity /
                                                        Math.pow(
                                                            10,
                                                            (commodities.purity
                                                                    .toString())
                                                                .length)) +
                                                commodities.sellCharge;
                                            return SizedBox(
                                              width: 120.h,
                                              child: Center(
                                                child: Text(
                                                  rateNow.toStringAsFixed(0),
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0.v,
                                  ),
                                  child: Container(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.05,
                                    decoration: const BoxDecoration(
                                      // border: Border.all(),
                                      color: Color(0xFF023930),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 180.h,
                                          child: Center(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text: "MINTEDBARS ",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1),
                                            ])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90.h,
                                          child: Center(
                                            child: Text(
                                              dToInt(value: commodities.unit) +
                                                  commodities.weight,
                                              style: CustomPoppinsTextStyles
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                        Consumer(
                                          builder: (context, refSell, child) {
                                            final cat =
                                                price + commodities.sellPremium;
                                            final askNow =
                                                (cat / 31.103) * 3.674;
                                            final rateNow = askNow *
                                                    (commodities.unit *
                                                        getUnitMultiplier(
                                                            commodities
                                                                .weight)) *
                                                    (commodities.purity /
                                                        Math.pow(
                                                            10,
                                                            (commodities.purity
                                                                    .toString())
                                                                .length)) +
                                                commodities.sellCharge;
                                            return SizedBox(
                                              width: 120.h,
                                              child: Center(
                                                child: Text(
                                                  rateNow.toStringAsFixed(0),
                                                  style: CustomPoppinsTextStyles
                                                      .bodyText1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ));
                    },
                  ),
                ],
              );
            } else {
              return Container(
                width: SizeUtils.width,
                // height: SizeUtils.height * 0.05,
                decoration: BoxDecoration(
                  // border: Border.all(),
                  color: appTheme.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    space(w: SizeUtils.width * 0.01),
                    Column(
                      children: [
                        Text(
                          "COMMODITY",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                        Text(
                          "سلعة",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                      ],
                    ),
                    space(w: 40.h),
                    Column(
                      children: [
                        Text(
                          "UNIT",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                        Text(
                          "وحدة",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // VerticalDivider(
                    //   color: appTheme.gray700,
                    // ),

                    Column(
                      children: [
                        Text(
                          "SELL",
                          textAlign: TextAlign.center,
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                        Text(
                          "يبيع",
                          textAlign: TextAlign.center,
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              );
            }
          },
          error: (error, stackTrace) {
            return const Text("Something Went Wrong");
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}
