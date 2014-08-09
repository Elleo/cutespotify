#ifndef CUSTOMICONPROVIDER_H
#define CUSTOMICONPROVIDER_H

#include <QQuickImageProvider>

class CustomIconProvider : public QQuickImageProvider
{
public:
    CustomIconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // CUSTOMICONPROVIDER_H
