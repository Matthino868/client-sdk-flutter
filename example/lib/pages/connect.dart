import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_example/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exts.dart';
import 'room.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:flutter_js/flutter_js.dart';
// import 'package:flutter/services.dart';
// import 'dart:js' as js;

class ConnectPage extends StatefulWidget {
  //
  const ConnectPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  //
  static const _storeKeyUri = 'uri';
  static const _storeKeyToken = 'token';
  static const _storeKeySimulcast = 'simulcast';
  static const _storeKeyAdaptiveStream = 'adaptive-stream';
  static const _storeKeyDynacast = 'dynacast';
  static const _storeKeyFastConnect = 'fast-connect';

  final _uriCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _simulcast = true;
  bool _adaptiveStream = true;
  bool _dynacast = true;
  bool _busy = false;
  bool _fastConnect = false;

  // late JavascriptRuntime flutterJs;

  @override
  void initState() {
    super.initState();
    _readPrefs();
    // flutterJs = getJavascriptRuntime();
  }

  @override
  void dispose() {
    _uriCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  // Read saved URL and Token
  Future<void> _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _uriCtrl.text = const bool.hasEnvironment('URL')
        ? const String.fromEnvironment('URL')
        : prefs.getString(_storeKeyUri) ?? '';
    _tokenCtrl.text = const bool.hasEnvironment('TOKEN')
        ? const String.fromEnvironment('TOKEN')
        : prefs.getString(_storeKeyToken) ?? '';
    // setState(() {
    //   _simulcast = prefs.getBool(_storeKeySimulcast) ?? true;
    //   _adaptiveStream = prefs.getBool(_storeKeyAdaptiveStream) ?? true;
    //   _dynacast = prefs.getBool(_storeKeyDynacast) ?? true;
    //   _fastConnect = prefs.getBool(_storeKeyFastConnect) ?? false;
    // });
  }

  // Save URL and Token
  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKeyUri, _uriCtrl.text);
    await prefs.setString(_storeKeyToken, _tokenCtrl.text);
    await prefs.setBool(_storeKeySimulcast, _simulcast);
    await prefs.setBool(_storeKeyAdaptiveStream, _adaptiveStream);
    await prefs.setBool(_storeKeyDynacast, _dynacast);
    await prefs.setBool(_storeKeyFastConnect, _fastConnect);
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      // Save URL and Token for convenience
      await _writePrefs();

      print('Connecting with url: ${_uriCtrl.text}, '
          'token: ${_tokenCtrl.text}...');

      //create new room
      final room = Room();

      // Create a Listener before connecting
      final listener = room.createListener();

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        _uriCtrl.text,
        _tokenCtrl.text,
        roomOptions: const RoomOptions(
            // adaptiveStream: _adaptiveStream,
            // dynacast: _dynacast,
            // defaultVideoPublishOptions: VideoPublishOptions(
            //   simulcast: _simulcast,
            // ),
            // defaultScreenShareCaptureOptions:
            //     const ScreenShareCaptureOptions(useiOSBroadcastExtension: true),
            ),
        // fastConnectOptions: _fastConnect
        //     ? FastConnectOptions(
        //         microphone: const TrackOption(enabled: true),
        //         camera: const TrackOption(enabled: true),
        //       )
        //     : null,
      );
      await Navigator.push<void>(
        ctx,
        MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      );
    } catch (error) {
      print('Could not connect $error');
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  // void _setSimulcast(bool? value) async {
  //   if (value == null || _simulcast == value) return;
  //   setState(() {
  //     _simulcast = value;
  //   });
  // }

  // void _setAdaptiveStream(bool? value) async {
  //   if (value == null || _adaptiveStream == value) return;
  //   setState(() {
  //     _adaptiveStream = value;
  //   });
  // }

  // void _setDynacast(bool? value) async {
  //   if (value == null || _dynacast == value) return;
  //   setState(() {
  //     _dynacast = value;
  //   });
  // }

  // void _setFastConnect(bool? value) async {
  //   if (value == null || _fastConnect == value) return;
  //   setState(() {
  //     _fastConnect = value;
  //   });
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: SvgPicture.asset(
                      'images/logo-dark.svg',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Server URL',
                      ctrl: _uriCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Token',
                      ctrl: _tokenCtrl,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 5),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: const [
                  //       Text('Simulcast'),
                  //       // Switch(
                  //       //   value: _simulcast,
                  //       //   onChanged: (value) => _setSimulcast(value),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 5),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: const [
                  //       Text('Adaptive Stream'),
                  //       // Switch(
                  //       //   value: _adaptiveStream,
                  //       //   onChanged: (value) => _setAdaptiveStream(value),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 5),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: const [
                  //       Text('Fast Connect'),
                  //       // Switch(
                  //       //   value: _fastConnect,
                  //       //   onChanged: (value) => _setFastConnect(value),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 25),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: const [
                  //       Text('Dynacast'),
                  //       // Switch(
                  //       //   value: _dynacast,
                  //       //   onChanged: (value) => _setDynacast(value),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: _busy ? null : () => _connect(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const Text('CONNECT'),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  ElevatedButton(
                    onPressed: () {
                      createToken();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const Text('TEST'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  int createToken() {
    // APIC2DyqDnPnvZo
    // iek3KSX9IJwvxfXGvBDVPoaszbBYqMW1RDUM1vy2gFO
    print('begin');
    String apiKey = 'APIC2DyqDnPnvZo';
    String apiSecret = 'iek3KSX9IJwvxfXGvBDVPoaszbBYqMW1RDUM1vy2gFO';
    Map<String, dynamic> grants = <String, dynamic>{};
    grants['identity'] = 'Arthur';
    var ttl = 900;
    grants['name'] = 'Arthur1';
    AccessToken at = AccessToken(apiKey, apiSecret, grants);
    print(at.toJwt());
    return 1;
  }
}

class AccessToken {
  String apiKey;

  String apiSecret;

  dynamic grants;

  String? identity;

  int? ttl;

  /// Creates a new AccessToken
  /// @param apiKey API Key, can be set in env LIVEKIT_API_KEY
  /// @param apiSecret Secret, can be set in env LIVEKIT_API_SECRET
  AccessToken(this.apiKey, this.apiSecret, Map<String, dynamic> options) {
    // apiKey ??= process.env.LIVEKIT_API_KEY;
    // if (!apiSecret) {
    //   apiSecret = process.env.LIVEKIT_API_SECRET;
    // }
    // if (!apiKey || !apiSecret) {
    //   throw Error('api-key and api-secret must be set');
    // } else if (typeof document !== 'undefined') {
    //   // check against document rather than window because deno provides window
    //   console.error(
    //     'You should not include your API secret in your web client bundle.\n\n' +
    //       'Your web client should request a token from your backend server which should then use ' +
    //       'the API secret to generate a token. See https://docs.livekit.io/client/connect/',
    //   );
    // }

    grants = <String, dynamic>{};
    identity = identity;
    // this.ttl = options?.ttl || defaultTTL;
    ttl = 900;
    // if (options?.metadata) {
    //   this.metadata = options.metadata;
    // }
    this.name = options['name'].toString();
    // if (options?.name) {
    //   this.name = options.name;
    // }
  }

  /// Adds a video grant to this token.
  /// @param grant
  // void addGrant(VideoGrant grant) {
  //   grants.video = grant;
  // }

  /// Set metadata to be passed to the Participant, used only when joining the room
  set metadata(String md) {
    grants['metadata'] = md;
  }

  set name(String name) {
    grants['name'] = name;
  }

  dynamic get sha256 {
    return grants['sha256'];
  }

  set sha256(dynamic sha) {
    grants.sha256 = sha;
  }

  /// @returns JWT encoded token
  String toJwt() {
    // APIhvRxzFGmjNMj
    // dpoPPM7SAoNZp3kaYbofyAUgRDYrDwca8eieA1Y68OvA
    // TODO: check for video grant validity
    final opts = JWT({
      'iss': 'APIhvRxzFGmjNMj',
      'sub': 'hi',
      // 'exp': ttl,
      'iat': 0,
      // 'nbf': 1681308109,
      // 'exp': 1681329709,
      // 'nbf': 0,
      'video': {
        'roomJoin': true, 'room': 'name-of-room',
      },
    });
    dynamic v1 = opts.payload;
    // dynamic v2 = opts.payload;
    print('opts1 $v1');
    // print('opts $v2');
    return opts
        .sign(SecretKey('dpoPPM7SAoNZp3kaYbofyAUgRDYrDwca8eieA1Y68OvA'));
    // return jwt.sign(grants, apiSecret, opts);
  }
}
