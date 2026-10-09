import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomNavItem {
  final IconData icon;
  final String label;
  final int badgeCount;

  const CustomNavItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomNavItem> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: Color(0x1A246BFF),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.electricBlue.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected ? AppColors.brightCyan : AppColors.textGrey,
                              size: isSelected ? 24 : 22,
                            ),
                          ),
                          if (item.badgeCount > 0)
                            Positioned(
                              top: -2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.alertRed,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.alertRed.withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.brightCyan : AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Small blue indicator line underneath active item
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 2.5,
                        width: isSelected ? 18 : 0,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
