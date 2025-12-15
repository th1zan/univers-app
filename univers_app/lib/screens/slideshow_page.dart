import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:univers_app/services/supabase_service.dart';
import 'package:univers_app/models/univers_asset_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/widgets/hold_button.dart';
import 'package:univers_app/core/app_state.dart';
import 'package:univers_app/core/themes.dart';
import 'package:univers_app/core/constants.dart';
import 'package:univers_app/services/audio_service.dart';
import 'package:univers_app/services/tts_service.dart';
import 'package:provider/provider.dart';

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

  bool isLoading = true;

  List<UniversAssetModel> assets = [];

  String? errorMessage;

  late PageController pageController;

  VideoPlayerController? videoPlayerController;

  ChewieController? chewieController;

  // Services audio et TTS
  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  late String universId;

  late String slug;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    universId = widget.univers.id;
    slug = widget.univers.slug;

    // Charger les assets une seule fois
    _loadAssets();

    // Initialisation TTS et audio différée après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });

    SupabaseService().preloadUniversAssets(slug);
  }

  Future<void> _initServices() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Initialiser TTS avec la langue sélectionnée
    await _ttsService.initialize(language: appState.selectedLanguage);

    // Démarrer la musique de fond si activée
    if (appState.backgroundMusicEnabled) {
      final encodedSlug = Uri.encodeComponent(slug);
      final musicUrl =
          '${ApiConstants.supabaseUrl}/storage/v1/object/public/univers/$encodedSlug/music.mp3';
      await _audioService.playBackgroundMusic(musicUrl);
    }
  }

  Future<void> _loadAssets() async {
    try {
      final loadedAssets = await SupabaseService().getUniversAssets(universId);
      if (mounted) {
        setState(() {
          assets = loadedAssets;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    videoPlayerController?.dispose();
    chewieController?.dispose();
    _audioService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void stopVideo() {
    setState(() {
      isPlayingVideo = false;
      videoPlayerController?.pause();
      videoPlayerController?.dispose();
      chewieController?.dispose();
      videoPlayerController = null;
      chewieController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // État de chargement
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5.0,
          color: Colors.white,
        ),
      );
    }

    // État d'erreur
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80.0, color: Colors.red),
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

    // Liste vide
    if (assets.isEmpty) {
      return const Center(
        child: Text(
          'Aucune image disponible',
          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Slideshow principal
    return Stack(
      children: [
        // Layout principal : PageView toujours présent
        Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  _speakCurrentTitle(assets);
                },
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final imageUrl =
                      ApiConstants.getStorageUrl(slug, asset.imageUrl);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (_) {
                      final videoExtension =
                          kIsWeb ? '_silent.webm' : '_silent.mp4';
                      final videoName = asset.imageUrl.replaceAll(
                        '.png',
                        videoExtension,
                      );
                      final encodedVideo = Uri.encodeComponent(videoName);
                      String videoUrl = asset.animationUrl ??
                          'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/${Uri.encodeComponent(slug)}/$encodedVideo';

                      playVideo(videoUrl);
                    },
                    child: Container(
                      color: AppColors.background, // Fond uniforme
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: kIsWeb ? BoxFit.contain : BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 100.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Texte en bas (toujours visible, même couleur)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 20.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background, // Fond uniforme
              ),
              child: Text(
                assets[currentIndex].getLocalizedTitle(
                    context.watch<AppState>().selectedLanguage),
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Toujours noir
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Overlay vidéo par-dessus le PageView
        if (isPlayingVideo && chewieController != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: stopVideo,
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController!.value.aspectRatio,
                    child: Chewie(controller: chewieController!),
                  ),
                ),
              ),
            ),
          ),

        // Boutons superposés (inchangés)
        Positioned(
          top: 20.0,
          left: 20.0,
          child: HoldButton(
            iconBuilder: () => Icons.arrow_back_rounded,
            onHold: () {
              Navigator.pop(context);
            },
            gradientColors: const [
              Color(0xFFFF6B9D),
              Color(0xFFFF8CAB),
            ],
            size: 70.0,
            iconSize: 40.0,
            holdDuration: const Duration(seconds: 2),
          ),
        ),

        if (kIsWeb)
          Positioned(
            left: 20.0,
            top: MediaQuery.of(context).size.height / 2 - 35,
            child: HoldButton(
              iconBuilder: () => Icons.arrow_back_ios_new_rounded,
              onHold: () {
                if (currentIndex > 0) {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              gradientColors: const [
                Colors.white,
                Color(0xFFF5F5F5),
              ],
              size: 70.0,
              iconSize: 40.0,
              holdDuration: const Duration(seconds: 1),
            ),
          ),
        if (kIsWeb)
          Positioned(
            right: 20.0,
            top: MediaQuery.of(context).size.height / 2 - 35,
            child: HoldButton(
              iconBuilder: () => Icons.arrow_forward_ios_rounded,
              onHold: () {
                if (currentIndex < assets.length - 1) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              gradientColors: const [
                Colors.white,
                Color(0xFFF5F5F5),
              ],
              size: 70.0,
              iconSize: 40.0,
              holdDuration: const Duration(seconds: 1),
            ),
          ),
      ],
    );
  }

  void _speakCurrentTitle(List<UniversAssetModel> assets) async {
    if (!_ttsService.isInitialized) return;

    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.textToSpeechEnabled) return; // TTS désactivé

    final title =
        assets[currentIndex].getLocalizedTitle(appState.selectedLanguage);
    if (title.isNotEmpty) {
      await _ttsService.speak(title, language: appState.selectedLanguage);
    }
  }

  Future<void> playVideo(String videoUrl) async {
    try {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await videoPlayerController?.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        allowFullScreen: false,
        allowMuting: true,
        aspectRatio: videoPlayerController!.value.aspectRatio,
      );

      // Petite pause pour transition fluide
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        isPlayingVideo = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (chewieController != null && isMuted) {
          chewieController?.setVolume(0.0);
        }
      });
    } catch (e) {
      // Ignore video initialization errors
    }
  }
}
