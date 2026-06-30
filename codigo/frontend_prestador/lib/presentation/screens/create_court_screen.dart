import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prestador_provider.dart';

class CreateCourtScreen extends StatefulWidget {
  const CreateCourtScreen({super.key});

  @override
  State<CreateCourtScreen> createState() => _CreateCourtScreenState();
}

class _CreateCourtScreenState extends State<CreateCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _nome = '';
  String _esporte = 'Tênis';
  String _precoHora = '';
  String _imagemUrl = '';
  String _endereco = '';
  String _descricao = '';

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<PrestadorProvider>(context, listen: false).createCourt(
        nome: _nome,
        esporte: _esporte,
        precoHora: _precoHora,
        imagemUrl: _imagemUrl.isEmpty ? null : _imagemUrl,
        endereco: _endereco.isEmpty ? null : _endereco,
        descricao: _descricao.isEmpty ? null : _descricao,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quadra criada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar quadra: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Nova Quadra'),
        backgroundColor: const Color(0xFF1B2838),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome da Quadra', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (v) => _nome = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Esporte', border: OutlineInputBorder()),
                value: _esporte,
                items: ['Tênis', 'Futebol', 'Vôlei', 'Basquete']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _esporte = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Preço por Hora (ex: 150.00)', border: OutlineInputBorder(), prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(v) == null) return 'Valor inválido';
                  return null;
                },
                onSaved: (v) => _precoHora = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL da Imagem (Opcional)', border: OutlineInputBorder()),
                keyboardType: TextInputType.url,
                onSaved: (v) => _imagemUrl = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Endereço (Opcional)', border: OutlineInputBorder()),
                onSaved: (v) => _endereco = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição (Opcional)', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (v) => _descricao = v ?? '',
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Quadra', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
