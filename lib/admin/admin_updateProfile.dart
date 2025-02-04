import 'package:flutter/material.dart';
import '../controller.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  @override
  void initState() {
    super.initState();

    setState((){});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Account information',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white, // Icon color
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/admin_home', (route) => false);
            }),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Column(
                children: [
                  Container(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.,
                      children: [
                        Text(
                          'CPP',
                          style: TextStyle(
                            color: Color.fromRGBO(250, 195, 44, 1),
                            fontSize: 48,
                            fontFamily: 'Montagu Slab',
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(255, 145, 145, 145),
                                offset: Offset(0, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Link',
                          style: TextStyle(
                            color: Color.fromARGB(255, 7, 7, 131),
                            fontSize: 32,
                            fontFamily: 'Montagu Slab',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //row to put the buttons
                  children: [
                    Padding(
                        //padding for all column
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                            //row to put image + name
                            children: [
                              Container(
                                width: 100, 
                                height: 100, 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFD233), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: ClipOval(
                                    child: picture_url != null
                                        ? admin_picture!
                                        : Container(
                                            color: Colors.grey,
                                          )),
                              ),
                              const SizedBox(width: 10.0),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      admin_name ?? 'Loading..',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 22,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.call,
                                          color: Color(0xFFFFD233),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          admin_phone ?? 'Loading..',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 15,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w100,
                                            height: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Color(0xFFFFD233),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          admin_email ?? 'Loading..',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 15,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w100,
                                            height: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])
                            ])),
                  ]),
              const SizedBox(height: 50),
              //Button
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/admin_changePFP', (route) => false);
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Change Profile Picture',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/admin_changeName');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Change Name',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/admin_changePw');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Change Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/admin_changePhone');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Change Phone Number',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),

                    ///////////////////////////
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
