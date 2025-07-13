import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'unity_vr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アプリタイトルセクション
                _buildTitleSection(),
                SizedBox(height: 50),
                
                // 機能説明カード（仕様書準拠）
                _buildFeatureCard(
                  icon: Icons.speed,
                  title: '60FPS安定動作',
                  subtitle: 'Metal API GPU最適化',
                  color: Color(0xFFE94560),
                ),
                SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.psychology,
                  title: 'Neural Engine AI',
                  subtitle: '8ms超高速推論',
                  color: Color(0xFF4CAF50),
                ),
                SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.hd,
                  title: '4K高画質撮影',
                  subtitle: 'GPU画像処理',
                  color: Color(0xFF2196F3),
                ),
                SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.people,
                  title: '1人検出・追跡',
                  subtitle: '最大人物自動選択',
                  color: Color(0xFFFF9800),
                ),
                
                SizedBox(height: 50),
                
                // メイン開始ボタン（仕様書：シンプルなUI）
                _buildStartButton(),
                
                SizedBox(height: 20),
                
                // 対応端末情報
                _buildDeviceInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFE94560).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Color(0xFFE94560),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Color(0xFFE94560),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        Text(
          'VR Avatar App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'GPU最適化・Neural Engine対応',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '「カメラを開いた瞬間、GPUパワーであなたが瞬時にVRキャラクターになる」',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFE94560),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return _isLoading
        ? Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFE94560),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'GPU最適化システム起動中...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startVRExperience,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: Color(0xFFE94560).withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'VR体験を開始',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildDeviceInfo() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_iphone,
                color: Colors.white60,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'iPhone XS以降対応',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Neural Engine搭載端末推奨',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Future<void> _startVRExperience() async {
    setState(() {
      _isLoading = true;
    });

    // カメラ権限チェック（仕様書：カメラアクセス必須）
    bool hasPermission = await _requestCameraPermission();
    
    if (hasPermission) {
      // 少し待機してGPU初期化をシミュレート
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      
      // Unity VR画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const UnityVRScreen(),
        ),
      );
    } else {
      _showPermissionDialog();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              Icons.camera_alt,
              color: Color(0xFFE94560),
            ),
            SizedBox(width: 10),
            Text(
              'カメラ権限が必要です',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'VR体験にはカメラアクセスが必要です。\n設定画面から権限を許可してください。',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFE94560),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}