import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:univers_app/models/univers_asset_model.dart';
import 'package:univers_app/integrations/supabase_service.dart';
import 'package:univers_app/models/univers_model.dart';

class SlideshowPage extends StatefulWidget {
  const SlideshowPage({required this.univers, super.key});

  final UniversModel univers;

  @override
  State<SlideshowPage> createState() {
    return _SlideshowPageState();
  }
}

class _SlideshowPageState extends State<SlideshowPage> {
  int currentIndex = 0;

  bool isMuted = false;

  bool isPlayingVideo = false;

  late PageController pageController;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    chewieController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  void stopVideo() {
    setState(() {
      isPlayingVideo = false;
      chewieController?.dispose();
      videoPlayerController?.dispose();
      chewieController = null;
      videoPlayerController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5e6d3),
      body: SafeArea(
        child: FutureBuilder<List<UniversAssetModel>>(
          future: SupabaseService().getUniversAssets(
            widget.univers.folder ?? '',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  color: Colors.white,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 80.0, color: Colors.red),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Oups ! Une erreur est survenue',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            final assets = snapshot.data ?? [];
            if (assets.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune image disponible',
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                ),
              );
            }
            return Stack(
              children: [
                if (!isPlayingVideo)
                  Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            return GestureDetector(
                              onTap: () {
                                String videoUrl = asset.animationUrl ??
                                    "https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/${widget.univers.folder}/${asset.imageUrl?.replaceAll('.png', '.mp4')}";
                                playVideo(videoUrl);
                              },
                              child: Center(
                                child: Image.network(
                                  "https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/${widget.univers.folder}/${asset.imageUrl}",
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.broken_image,
                                    size: 100.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          assets[currentIndex].title ?? '',
                          style: const TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                if (isPlayingVideo && chewieController != null)
                  GestureDetector(
                    onTap: stopVideo,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Chewie(controller: chewieController!),
                      ),
                    ),
                  ),
                Positioned(
                  top: 20.0,
                  left: 20.0,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: const CircleBorder(),
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 36.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20.0,
                  right: 20.0,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: const CircleBorder(),
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isMuted = !isMuted;
                          if (videoPlayerController != null) {
                            videoPlayerController
                                ?.setVolume(isMuted ? 0.0 : 1.0);
                          }
                        });
                      },
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 36.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                if (kIsWeb)
                  Positioned(
                    left: 20.0,
                    top: MediaQuery.of(context).size.height / 2 - 40,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: const CircleBorder(),
                      elevation: 4.0,
                      child: InkWell(
                        onTap: () {
                          if (currentIndex > 0) {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 36.0,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (kIsWeb)
                  Positioned(
                    right: 20.0,
                    top: MediaQuery.of(context).size.height / 2 - 40,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: const CircleBorder(),
                      elevation: 4.0,
                      child: InkWell(
                        onTap: () {
                          if (currentIndex < assets.length - 1) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 36.0,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void playVideo(String animationUrl) {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(animationUrl));
    videoPlayerController!.initialize().then((_) {
      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: true,
          looping: false,
          showControls: false,
          allowFullScreen: false,
        );
        isPlayingVideo = true;
        if (isMuted) {
          videoPlayerController?.setVolume(0.0);
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (videoPlayerController != null && isMuted) {
        videoPlayerController?.setVolume(0.0);
      }
    });
  }
}
