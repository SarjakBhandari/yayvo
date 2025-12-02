import 'package:flutter/material.dart';
import 'package:yayvo/screens/login.screen.dart';
import 'package:yayvo/screens/register_consumer.screen.dart';
import 'package:yayvo/screens/register_retailer.screen.dart';
import 'package:yayvo/widgets/my_button.dart';
import 'package:yayvo/widgets/my_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 23, 26, 28),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyLogo(size: 150, radius: 40),
              const SizedBox(height: 30),
              const Text(
                "Discover lifestyle through emotions.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Choose your role to get Started.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 45,
                child: MyButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> RegisterConsumerScreen()),
                      );
                    });
                    },
                  text: "I'm a Consumer",
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 45,
                child: MyButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> RegisterRetailerScreen()),
                      );
                    });
                  },
                  text: "I'm a Retailer",
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> LoginScreen()),
                      );
                    });
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Already registered? ",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
