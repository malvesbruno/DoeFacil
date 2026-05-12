import 'package:doe_facil/signupPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  
  // Controladores para capturar o texto dos inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Método para logar
  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // O StreamBuilder no main vai trocar a tela automaticamente
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erro ao autenticar")),
      );
    }
  }

  // É boa prática dar dispose nos controllers para evitar vazamento de memória
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Seção Superior: Logo ---
                    Column(
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'DoeFacil',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                        const Text(
                          'Bem-vindo ao Admin',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),

                    // --- Seção Central: Formulário ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("EMAIL"),
                          _buildTextField("admin@doefacil.org", icon: Icons.email_outlined, controller: _emailController),
                          
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel("SENHA"),
                              TextButton(
                                onPressed: () {},
                                child: const Text("Esqueci minha senha", style: TextStyle(fontSize: 12, color: Colors.blue)),
                              ),
                            ],
                          ),
                          _buildPasswordField(controller: _passwordController),
                          
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _signIn, // Chama o método de login
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4332),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.login, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Seção Inferior: Rodapé ---
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Não tem uma conta? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (builder) => SignUpScreen()));
                              },
                              child: const Text("Criar uma conta", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("ACESSO SEGURO", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.1)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSecurityBadge(Icons.verified_user, "SSL ENCRYPTED"),
                            const SizedBox(width: 20),
                            _buildSecurityBadge(Icons.shield, "GDPR COMPLIANT"),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      );

  // Adicionado o parâmetro controller aqui
  Widget _buildTextField(String hint, {required IconData icon, required TextEditingController controller}) => TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  // Adicionado o parâmetro controller aqui
  Widget _buildPasswordField({required TextEditingController controller}) => TextField(
        controller: controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: "••••••••",
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _buildSecurityBadge(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );
}