#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>

static unsigned char cipherText[32] = {0x8d,0x20,0xe5,0x05,0x6a,0x8d,0x24,0xd0,0x46,0x2c,0xe7,0x4e,0x49,0x04,0xc1,0xb5,0x13,0xe1,0x0d,0x1d,0xf4,0xa2,0xef,0x2a,0xd4,0x54,0x0f,0xae,0x1c,0xa0,0xaa,0xf9};

int main() {
	int fkSize;
	char *token;
	FILE *fileR;
	fileR = fopen("words.txt", "r");
        if(fileR) {
                fseek(fileR, 0, SEEK_END);
                fkSize = ftell(fileR);
                rewind(fileR);
                char text[fkSize];
                fread(text, 1, fkSize, fileR);
                token = strtok(text, "\n");
                while(token != NULL) {
			if((token[0] <= 57 && token[0] >= 48)
			|| (token[0] <= 90 && token[0] >= 65)
			|| (token[0] <= 122 && token[0] >= 97)) {
				while(strlen(token) < 16) {
					char temp1[strlen(token)+1];
					strncpy(temp1, token, strlen(token));
					strncat(temp1, " ", 1);
					token = temp1;
				}
				char temp2[strlen(token)];
				strncpy(temp2, token, strlen(token));
				int keyCheck;
				keyCheck = do_crypt(1, temp2);
				if(keyCheck == 1) {
					printf("\n'%s' is the correct key.\n\n", temp2);
					break;
				}
			}
                	token = strtok(NULL, "\n");
		}
		fclose(fileR);
	}
	return 0;
}

int do_crypt(int do_encrypt, char token[]) {
        /* Allow enough space in output buffer for additional block */
        unsigned char inbuf[1024], outbuf[1024 + EVP_MAX_BLOCK_LENGTH];
        int inlen, outlen;
	int i;
        EVP_CIPHER_CTX ctx;
        unsigned char key[strlen(token)];
	strncpy(key, token, strlen(token));
        unsigned char iv[] = {0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};

        /* Don't set key or IV right away; we want to check lengths */
        EVP_CIPHER_CTX_init(&ctx);
        EVP_CipherInit_ex(&ctx, EVP_aes_128_cbc(), NULL, NULL, NULL,
                do_encrypt);
        OPENSSL_assert(EVP_CIPHER_CTX_key_length(&ctx) == 16);
        OPENSSL_assert(EVP_CIPHER_CTX_iv_length(&ctx) == 16);

        /* Now we can set key and IV */
        EVP_CipherInit_ex(&ctx, NULL, NULL, key, iv, do_encrypt);

	/* Known plaintext */
	strncpy(inbuf, "This is a top secret.", 21);
	inlen = strlen(inbuf);

        if(!EVP_CipherUpdate(&ctx, outbuf, &outlen, inbuf, inlen)) {
                /* Error */
                EVP_CIPHER_CTX_cleanup(&ctx);
                return 0;
        }
	for(i=0;i<strlen(outbuf);i++) {
		if(outbuf[i] != cipherText[i]) {
        		EVP_CIPHER_CTX_cleanup(&ctx);
			return 0; // if no match, return 0.
		}
        }
        if(!EVP_CipherFinal_ex(&ctx, outbuf, &outlen)){
                /* Error */
                EVP_CIPHER_CTX_cleanup(&ctx);
                return 0;
        }
	for(i=0;i<strlen(outbuf);i++) {
		if(outbuf[i] != cipherText[i+16]) {
        		EVP_CIPHER_CTX_cleanup(&ctx);
                        return 0; // if no match, return 0.
                }
	}

        EVP_CIPHER_CTX_cleanup(&ctx);
        return 1; // if everything is equal, return 1.
}
