package com.sap.test;

import org.springframework.cloud.bindings.Binding;
import org.springframework.cloud.bindings.Bindings;

public class Client {

    public static void main(final String[] args) {
        final Bindings bindings = new Bindings("./../service-binding-root");
        System.out.printf("Found %d bindings.\n", bindings.getBindings().size());
        for (final Binding b : bindings.getBindings()) {
            System.out.printf("%s: name=%s, type=%s, provider=%s\n", b.getPath().toString(), b.getName(), b.getType(),
                b.getProvider());
            System.out.printf("  %s\n\n", b.getSecret());
        }
    }
}
