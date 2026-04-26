import 'package:flutter/material.dart';

class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discover People Skeletons
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: SkeletonItem(width: 100, height: 12),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonCircle(radius: 28),
                    SizedBox(height: 8),
                    SkeletonItem(width: 40, height: 10),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          
          // Recent Chats Skeletons
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: SkeletonItem(width: 100, height: 12),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SkeletonCircle(radius: 25),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonItem(width: 120, height: 14),
                          const SizedBox(height: 8),
                          SkeletonItem(width: double.infinity, height: 10, opacity: 0.03),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const SkeletonItem(width: 40, height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonItem extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const SkeletonItem({
    super.key, 
    required this.width, 
    required this.height,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double radius;

  const SkeletonCircle({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}
