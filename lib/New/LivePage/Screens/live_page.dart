import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:naif_gold/Core/app_export.dart';
import 'package:naif_gold/Models/spread_document_model.dart';
import 'dart:math' as Math;
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../Core/CommenWidgets/custom_image_view.dart';
import '../../NewsScreen/Controller/news_controller.dart';
import '../Controller/live_controller.dart';

import '../Repository/live_repository.dart';
import 'commodity_list.dart';
import 'live_rate_widget.dart';

final rateBidValue = StateProvider(
  (ref) {
    return 0.0;
  },
);

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState createState() => _LivePageState();
}

final spreadDataProvider2 = StateProvider<SpreadDocumentModel?>(
  (ref) {
    return null;
  },
);

class _LivePageState extends ConsumerState<LivePage> {
  late Timer _timer;
  String formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
  final formattedTimeProvider = StateProvider(
    (ref) => DateFormat('h:mm a').format(DateTime.now()),
  );
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        _updateTime(timer);
        // convertTimes(timer);
      },
    );
  }

  final goldAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  final silverAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  void _updateTime(Timer timer) {
    ref.read(formattedTimeProvider.notifier).update(
          (state) => DateFormat('h:mm a').format(DateTime.now()),
        );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final bannerBool = StateProvider.autoDispose(
    (ref) => false,
  );

  String getMarketStatus() {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;

    DateTime nextOpeningTime;
    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      if (now.hour == 0 && now.minute == 0) {
        return 'Market is open.';
      } else {
        // Next opening time is tomorrow at midnight
        nextOpeningTime =
            DateTime(now.year, now.month, now.day).add(Duration(days: 1));
      }
    } else {
      // It's weekend, next opening is on Monday
      int daysUntilMonday = (DateTime.monday - currentDay + 7) % 7;
      nextOpeningTime = DateTime(now.year, now.month, now.day)
          .add(Duration(days: daysUntilMonday));
    }

    Duration timeUntilOpen = nextOpeningTime.difference(now);
    int days = timeUntilOpen.inDays;
    int hours = timeUntilOpen.inHours % 24;
    int minutes = timeUntilOpen.inMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days d${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours h${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes m${minutes > 1 ? 's' : ''}');

    String countdownText = parts.join(', ');

    return 'Market is closed. It will open in $countdownText.';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    // width: SizeUtils.width / 3,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: appTheme.whiteA700,
                        ),
                        Text(
                          DateFormat("MMM dd yyyy").format(DateTime.now()),
                          style: CustomPoppinsTextStyles.bodyText,
                        ),
                        Text(
                            DateFormat("EEEE")
                                .format(DateTime.now())
                                .toUpperCase(),
                            style: CustomPoppinsTextStyles.bodyText)
                      ],
                    ),
                  ),
                  CustomImageView(
                    imagePath: ImageConstants.logo,
                    width: 80.h,
                  ),
                  SizedBox(
                    // width: SizeUtils.width / 3,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          color: appTheme.whiteA700,
                        ),
                        Consumer(
                          builder: (context, ref, child) => Text(
                            ref.watch(formattedTimeProvider),
                            style: CustomPoppinsTextStyles.bodyText,
                          ),
                        ),
                        space()
                      ],
                    ),
                  )
                ],
              ),
              space(),
              Container(
                height: 55.h,
                decoration: BoxDecoration(
                  color: appTheme.gold,
                  borderRadius: BorderRadius.circular(15.v),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    space(w: 50.h),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "\$BUY",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                        Text(
                          'شراء',
                          style: CustomPoppinsTextStyles.bodyText1White,
                        )
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "\$SELL",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                        Text(
                          "بيع",
                          style: CustomPoppinsTextStyles.bodyText1White,
                        ),
                      ],
                    ),
                    space(w: 50.h)
                  ],
                ),
              ),
              space(),

              ///new
              Consumer(
                builder: (context, ref1, child) {
                  return ref1.watch(spotRateProvider).when(
                    data: (spotRate) {
                      if (spotRate != null) {
                        final liveRateData = ref1.watch(liveRateProvider);
                        if (liveRateData != null) {
                          final spreadNow = spotRate.info;
                          WidgetsBinding.instance.addPostFrameCallback(
                            (timeStamp) {
                              ref1.read(bannerBool.notifier).update(
                                (state) {
                                  return liveRateData.gold?.marketStatus !=
                                          "TRADEABLE"
                                      ? true
                                      : false;
                                },
                              );
                              ref1.read(rateBidValue.notifier).update(
                                (state) {
                                  return liveRateData.gold?.bid ??
                                      0 + (spreadNow.goldBidSpread);
                                },
                              );
                              ref1.read(goldAskPrice.notifier).update(
                                (state) {
                                  final res = (liveRateData.gold?.bid ??
                                      0 + (spreadNow.goldAskSpread));
                                  return res;
                                },
                              );
                              ref1.read(silverAskPrice.notifier).update(
                                (state) {
                                  final res = (liveRateData.gold?.bid ??
                                      0 +
                                          (spreadNow.goldAskSpread) +
                                          (spreadNow.goldBidSpread) +
                                          0.5);
                                  return res;
                                },
                              );
                            },
                          );
                          return Column(
                            children: [
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Gold",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize)),
                                        TextSpan(
                                            text: "\n ذهب",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 25.fSize)),
                                      ])),
                                      Column(
                                        children: [
                                          ValueDisplayWidget(
                                              value: (liveRateData.gold?.bid ??
                                                  0 +
                                                      (spreadNow
                                                          .goldAskSpread))),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "${liveRateData.gold?.low ?? 0 + (spreadNow.goldLowMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ValueDisplayWidget2(
                                              value: liveRateData.gold?.bid ??
                                                  0 +
                                                      spreadNow.goldBidSpread +
                                                      spreadNow.goldAskSpread +
                                                      0.5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "${liveRateData.gold?.high ?? 0 + (spreadNow.goldHighMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Silver",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize)),
                                        TextSpan(
                                            text: "\n فضة",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 25.fSize)),
                                      ])),
                                      Column(
                                        children: [
                                          ValueDisplayWidgetSilver1(
                                              value: (liveRateData
                                                      .silver?.bid ??
                                                  0 +
                                                      (spreadNow
                                                              .silverBidSpread ??
                                                          0))),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "${liveRateData.silver?.low ?? 0 + (spreadNow.silverLowMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ValueDisplayWidgetSilver2(
                                              // value: 0,
                                              value: (liveRateData
                                                      .silver?.bid ??
                                                  0 +
                                                      (spreadNow
                                                              .silverBidSpread ??
                                                          0) +
                                                      (spreadNow
                                                              .silverAskSpread ??
                                                          0) +
                                                      0.05)),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "${liveRateData.silver?.high ?? 0 + (spreadNow.silverHighMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                            ],
                          );
                        } else {
                          print("#########Live Data Is NULL#######");
                          return Column(
                            children: [
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Gold",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          const ValueDisplayWidget(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const ValueDisplayWidget2(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Silver",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          const ValueDisplayWidgetSilver1(
                                              value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const ValueDisplayWidgetSilver2(
                                              value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                            ],
                          );
                        }
                      } else {
                        print("#########Spot Rate Is NULL#######");
                        return Column(
                          children: [
                            Card(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Gold",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      children: [
                                        const ValueDisplayWidget(value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const ValueDisplayWidget2(value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            space(),
                            Card(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Silver",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      children: [
                                        const ValueDisplayWidgetSilver1(
                                            value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const ValueDisplayWidgetSilver2(
                                            value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            space(),
                          ],
                        );
                      }
                    },
                    error: (error, stackTrace) {
                      print("###Live Page Error ERROR###");
                      print(error.toString());
                      print(stackTrace);
                      return const Center(
                        child: Text("Something Went Wrong"),
                      );
                    },
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),

              ///new
              Consumer(
                builder: (context, ref2, child) => CommodityList(
                  price: ref2.watch(silverAskPrice),
                ),
              ),

              Consumer(
                builder: (context, ref1, child) {
                  return ref1.watch(newsProvider).when(
                        data: (data123) {
                          if (data123 != null) {
                            return AutoScrollText(
                              delayBefore: const Duration(seconds: 3),
                              "${data123.news.news[0].description}",
                              style: CustomPoppinsTextStyles.bodyText,
                            );
                          } else {
                            return Text(
                              "NO News",
                              style: CustomPoppinsTextStyles.bodyText,
                            );
                          }
                        },
                        error: (error, stackTrace) {
                          print(stackTrace);
                          print(error.toString());
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(),
                      );
                },
              ),
            ],
          ),
        ),
        Positioned(
          top: 15.v,
          right: 50.h,
          child: Transform.rotate(
            angle: -Math.pi / 4,
            child: Consumer(
              builder: (context, refBanner, child) {
                return Visibility(
                  visible: refBanner.watch(bannerBool),

                  child: Container(
                    width: SizeUtils.width,
                    height: 30.h,
                    color: Colors.red,
                    child: Center(
                      child: AutoScrollText(
                        delayBefore: const Duration(seconds: 3),
                        getMarketStatus(),
                        style: CustomPoppinsTextStyles.buttonText,
                      ),
                    ),
                  ),
                  // visible: refBanner.watch(bannerBool),
                  // child: RunningTextBanner(
                  //   text: getMarketStatus(),
                  //   textStyle:
                  //       CustomPoppinsTextStyles.titleSmallWhiteA700SemiBold_1,
                  //   speed: const Duration(seconds: 15),
                  // ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
