using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraShake : MonoBehaviour
{
    public static CameraShake instance;

    private CinemachineVirtualCamera m_camera;
    private float m_shakeTimer;
    private float m_shakeTimerTotal;
    private float m_startingIntensity;

    private void Awake()
    {
        instance = this;
        m_camera = GetComponent<CinemachineVirtualCamera>();
    }

    private void Update()
    {
        if(m_shakeTimer > 0)
        {
            m_shakeTimer -= Time.deltaTime;
            if(m_shakeTimer <= 0)
            {
                CinemachineBasicMultiChannelPerlin l_cinemachineBasicMultiChannelPerlin = m_camera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();

                l_cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = Mathf.Lerp(m_startingIntensity, 0f, 1-(m_shakeTimer/m_shakeTimerTotal));
            }
        }
    }
    public void DoShake(float intensity, float time)
    {
        CinemachineBasicMultiChannelPerlin l_cinemachineBasicMultiChannelPerlin = m_camera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();

        l_cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = intensity;
        m_startingIntensity = intensity;

        m_shakeTimer = time;
        m_shakeTimerTotal = time;
    }
}
