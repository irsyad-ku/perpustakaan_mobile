<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Mendaftarkan pengguna baru ke dalam sistem.
     * 
     * @param Request $request Data input pengguna (name, email, password, password_confirmation).
     * @return \Illuminate\Http\JsonResponse Respon sukses dengan data user dan token, atau error validasi.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Melakukan login otomatis setelah registrasi berhasil untuk memberikan pengalaman pengguna yang mulus
        $token = Auth::login($user);

        return response()->json([
            'status'  => 'success',
            'message' => 'Registrasi berhasil',
            'user'    => $user,
            'token'   => $token,
            'token_type' => 'bearer',
            'expires_in' => Auth::factory()->getTTL() * 60,
        ], 201);
    }

    /**
     * Melakukan autentikasi pengguna dan mengembalikan token akses.
     * 
     * @param Request $request Kredensial pengguna (email, password).
     * @return \Illuminate\Http\JsonResponse Token JWT jika berhasil, atau pesan error jika gagal.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $credentials = $request->only('email', 'password');

        // Menggunakan library JWT-Auth untuk memeriksa kredensial dan menghasilkan token
        if (!$token = Auth::attempt($credentials)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email atau password salah'
            ], 401);
        }

        return response()->json([
            'status'       => 'success',
            'token'        => $token,
            'token_type'   => 'bearer',
            'expires_in'   => Auth::factory()->getTTL() * 60,
            'user'         => Auth::user(),
        ]);
    }

    /**
     * Memperbarui (refresh) token JWT yang sedang aktif.
     * 
     * @return \Illuminate\Http\JsonResponse Token baru dengan masa berlaku yang diperbarui.
     */
    public function refresh()
    {
        $token = Auth::refresh();
        return response()->json([
            'status'     => 'success',
            'token'      => $token,
            'token_type' => 'bearer',
            'expires_in' => Auth::factory()->getTTL() * 60,
        ]);
    }

    /**
     * Mengakhiri sesi pengguna dengan membatalkan token yang aktif.
     * 
     * @return \Illuminate\Http\JsonResponse Pesan konfirmasi logout.
     */
    public function logout()
    {
        Auth::logout();
        return response()->json(['status' => 'success', 'message' => 'Logout berhasil']);
    }

    /**
     * Mendapatkan profil data pengguna yang sedang terautentikasi.
     * 
     * @return \Illuminate\Http\JsonResponse Objek user saat ini.
     */
    public function me()
    {
        return response()->json([
            'status' => 'success',
            'user'   => Auth::user(),
        ]);
    }
}
