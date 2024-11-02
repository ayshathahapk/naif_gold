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
import 'package:naif_gold/main.dart';
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
    _homeController.dispose();
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

  final ScrollController _homeController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
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
              space(),
              Container(
                height: 55.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF045147),
                  // Color(0xFF023930)
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.v),
                      topRight: Radius.circular(15.v)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    space(w: 50.h),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "BID",
                          style: CustomPoppinsTextStyles.bodyText1Gold,
                        ),
                        Text(
                          'شراء',
                          style: CustomPoppinsTextStyles.bodyText1Gold,
                        )
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "ASK",
                          style: CustomPoppinsTextStyles.bodyText1Gold,
                        ),
                        Text(
                          "بيع",
                          style: CustomPoppinsTextStyles.bodyText1Gold,
                        ),
                      ],
                    ),
                    space(w: 50.h)
                  ],
                ),
              ),

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
                                  final res = ((((liveRateData.gold!.bid +
                                              spreadNow.goldBidSpread) +
                                          spreadNow.goldAskSpread) +
                                      0.5));
                                  return res;
                                },
                              );
                            },
                          );
                          return Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFF023930)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.15,
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
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize)),
                                      TextSpan(
                                          text: "\n ذهب",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 25.fSize)),
                                    ])),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ValueDisplayWidget(
                                              value: (liveRateData.gold!.bid +
                                                  (spreadNow.goldBidSpread))),
                                          space(h: 5.v),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.h,
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
                                    ),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ValueDisplayWidget2(
                                              value: (((liveRateData.gold!.bid +
                                                          spreadNow
                                                              .goldBidSpread) +
                                                      spreadNow.goldAskSpread) +
                                                  0.5)),
                                          space(
                                            h: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.h,
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
                                    ),
                                  ],
                                ),
                              ),
                              space(h: 1.v),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(15.h),
                                        bottomLeft: Radius.circular(15.h)),
                                    color: const Color(0xFF023930)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.15,
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
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize)),
                                      TextSpan(
                                          text: "\n فضة",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 25.fSize)),
                                    ])),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ValueDisplayWidgetSilver1(
                                              value: (liveRateData.silver!.bid +
                                                  spreadNow.silverBidSpread)),
                                          space(h: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.h,
                                              ),
                                              Text(
                                                (liveRateData.silver?.low ??
                                                        0 +
                                                            (spreadNow
                                                                .silverLowMargin))
                                                    .toStringAsFixed(2),
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ValueDisplayWidgetSilver2(
                                              // value: 0,
                                              value: (((liveRateData
                                                              .silver!.bid +
                                                          spreadNow
                                                              .silverBidSpread) +
                                                      spreadNow
                                                          .silverAskSpread) +
                                                  0.05)),
                                          space(h: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.h,
                                              ),
                                              Text(
                                                (liveRateData.silver?.high ??
                                                        0 +
                                                            (spreadNow
                                                                .silverHighMargin))
                                                    .toStringAsFixed(2),
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              space(),
                            ],
                          );
                        } else {
                          print("#########Live Data Is NULL#######");
                          return Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFF023930)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.15,
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
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize)),
                                      TextSpan(
                                          text: "\n ذهب",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 25.fSize)),
                                    ])),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const ValueDisplayWidget(value: 0.0),
                                          space(h: 5.v),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.h,
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
                                    ),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const ValueDisplayWidget2(value: 0.0),
                                          space(
                                            h: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.h,
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
                                    ),
                                  ],
                                ),
                              ),
                              space(h: 1.v),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(15.h),
                                        bottomLeft: Radius.circular(15.h)),
                                    color: const Color(0xFF023930)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.15,
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
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize)),
                                      TextSpan(
                                          text: "\n فضة",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.whiteA700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 25.fSize)),
                                    ])),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const ValueDisplayWidgetSilver1(
                                              value: 0.0),
                                          space(h: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.h,
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
                                    ),
                                    Container(
                                      height: SizeUtils.height * 0.1,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appTheme.gray500),
                                        color: const Color(0xFF045147),
                                        // Color(0xFF023930)
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.v)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const ValueDisplayWidgetSilver2(
                                              // value: 0,
                                              value: 0.0),
                                          space(h: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.h,
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
                                    ),
                                  ],
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
                            Container(
                              decoration:
                                  const BoxDecoration(color: Color(0xFF023930)),
                              width: SizeUtils.width,
                              height: SizeUtils.height * 0.15,
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
                                            color: appTheme.whiteA700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.fSize)),
                                    TextSpan(
                                        text: "\n ذهب",
                                        style: GoogleFonts.poppins(
                                            // fontFamily: marine,
                                            color: appTheme.whiteA700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 25.fSize)),
                                  ])),
                                  Container(
                                    height: SizeUtils.height * 0.1,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: appTheme.gray500),
                                      color: const Color(0xFF045147),
                                      // Color(0xFF023930)
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.v)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const ValueDisplayWidget(value: 0.0),
                                        space(h: 5.v),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                              size: 20.h,
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
                                  ),
                                  Container(
                                    height: SizeUtils.height * 0.1,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: appTheme.gray500),
                                      color: const Color(0xFF045147),
                                      // Color(0xFF023930)
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.v)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const ValueDisplayWidget2(value: 0.0),
                                        space(
                                          h: 5,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                              size: 20.h,
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
                                  ),
                                ],
                              ),
                            ),
                            space(h: 1.v),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15.h),
                                      bottomLeft: Radius.circular(15.h)),
                                  color: const Color(0xFF023930)),
                              width: SizeUtils.width,
                              height: SizeUtils.height * 0.15,
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
                                            color: appTheme.whiteA700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.fSize)),
                                    TextSpan(
                                        text: "\n فضة",
                                        style: GoogleFonts.poppins(
                                            // fontFamily: marine,
                                            color: appTheme.whiteA700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 25.fSize)),
                                  ])),
                                  Container(
                                    height: SizeUtils.height * 0.1,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: appTheme.gray500),
                                      color: const Color(0xFF045147),
                                      // Color(0xFF023930)
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.v)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const ValueDisplayWidgetSilver1(
                                            value: 0.0),
                                        space(h: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                              size: 20.h,
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
                                  ),
                                  Container(
                                    height: SizeUtils.height * 0.1,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: appTheme.gray500),
                                      color: const Color(0xFF045147),
                                      // Color(0xFF023930)
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.v)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const ValueDisplayWidgetSilver2(
                                            // value: 0,
                                            value: 0.0),
                                        space(h: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                              size: 20.h,
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
                                  ),
                                ],
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
              space(h: 10.h),

              ///new
              Consumer(
                builder: (context, ref2, child) => CommodityList(
                  price: ref2.watch(silverAskPrice),
                ),
              ),

              space(h: 10.v),
              Consumer(
                builder: (context, ref1, child) {
                  return ref1.watch(newsProvider).when(
                        data: (data123) {
                          if (data123 != null) {
                            return AutoScrollText(
                              delayBefore: const Duration(seconds: 3),
                              data123.news.news[0].description,
                              style: CustomPoppinsTextStyles.bodyText,
                            );
                          } else {
                            return AutoScrollText(
                              delayBefore: const Duration(seconds: 3),
                              "NAIF GOLD NAIF GOLD NAIF GOLD NAIF GOLD NAIF GOLD NAIF GOLD ",
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
          right: 90.h,
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
                        "Market is closed. It will open soon!  Market is closed. It will open soon!",
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
