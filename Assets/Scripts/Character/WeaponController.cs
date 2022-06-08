using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class WeaponController : MonoBehaviour
{

    [Header("Arrow Behaviour")]
    [SerializeField]
    private Weapon m_weapon;

    [SerializeField]
    private string m_enemyTag;

    [SerializeField]
    private float m_maxFirePower;

    [SerializeField]
    private float m_minFirePower;

    [SerializeField]
    private float m_firePowerSpeed;

    public float m_firePower;

    private bool m_fire;

    [SerializeField]
    [Range(0.2f, 0.5f)]
    private float m_reloadTime;

    private float m_reloadTimer;

    [Header("Crosshair reticle")]
    [SerializeField]
    private UI_Manager m_UI;

    [SerializeField]
    private float m_minRadius;

    private float m_currentRadius;

    [SerializeField]
    private float m_maxRadius;

    [SerializeField]
    private int m_Steps;

    [SerializeField]
    private float m_SpeedCircle;
    
    private float m_maxSpeedCircle;
    private float m_minSpeedCircle;

    [Header("Inputs")]
    [SerializeField]
    private PlayerInput playerInput;
    [SerializeField]
    private InputAction m_shootArrow;

    [Header("Animation")]
    private AnimationController m_animController;

    [Header("VFX")]
    [SerializeField]
    private GameObject m_arrowVFX;
    private void Awake()
    {
        playerInput = GetComponent<PlayerInput>();
        m_animController = GetComponent<AnimationController>();

        m_shootArrow = playerInput.actions["Shoot"];
        m_fire = false;

        m_minRadius = 3f;
        m_currentRadius = 50f;
        m_maxRadius = 50f;
        m_Steps = 1000;
        m_SpeedCircle = 5f;
        m_maxSpeedCircle = 100f;
        m_minSpeedCircle = 50f;
    }

    private void Update()
    {
        m_firePowerSpeed = m_maxFirePower - m_minFirePower;
        if (m_shootArrow.triggered && m_reloadTimer < 0f)
        {
            m_firePower = m_minFirePower;
            m_fire = true;
        }

        if (m_fire)
        {
            m_animController.AnimationAiming(true);
            m_arrowVFX.SetActive(true);
            if (Time.timeScale > 0f)
            {
                if (m_firePower < m_maxFirePower)
                {
                    m_firePower += (Time.deltaTime * m_firePowerSpeed) / Time.timeScale;
                }

                m_SpeedCircle += (Time.deltaTime * 40f) / Time.timeScale;
                m_currentRadius -= (Time.deltaTime * m_SpeedCircle) / Time.timeScale;
            }
            else
            {
                if (m_firePower < m_maxFirePower)
                {
                    m_firePower += Time.deltaTime * m_firePowerSpeed;
                }

                m_SpeedCircle += Time.deltaTime * 40f;
                m_currentRadius -= Time.deltaTime * m_SpeedCircle;
            }
        }
        else
        {
            m_animController.AnimationAiming(false);
            m_arrowVFX.SetActive(false);

            if (Time.timeScale > 0f)
            {
                m_SpeedCircle -= (Time.deltaTime * 50f) / Time.timeScale;
                m_currentRadius += (Time.deltaTime * m_SpeedCircle) / Time.timeScale;
            }
            else
            {
                m_SpeedCircle -= Time.deltaTime * 50f;
                m_currentRadius += Time.deltaTime * m_SpeedCircle;
            }
        }

        if (m_shootArrow.WasReleasedThisFrame() && m_fire)
        {
            if(m_firePower >= m_maxFirePower)
            {
                m_animController.AnimationShootLong();
                m_weapon.FireArrow(m_firePower, false);
            }
            else
            {
                m_animController.AnimationShootShort();
                m_weapon.FireArrow(m_firePower, true);
            }
            m_reloadTimer = m_reloadTime;
            m_fire = false;
        }

        if(m_reloadTimer >= 0)
        {
            if(Time.timeScale > 0f)
            {
                m_reloadTimer -= Time.deltaTime / Time.timeScale;
            }
            else
            {
                m_reloadTimer -= Time.deltaTime;
            }
        }

        checkRadiusCircle();

        m_UI.SetAlphaCirlce(UtilsGyromitra.InversedNormalizedFloatFromARange(m_maxRadius, m_minRadius, m_currentRadius));

        m_UI.DrawCircle(m_Steps, m_currentRadius);
    }

    /// <summary>
    /// Check if the radius of the reticle for his max and min radius
    /// </summary>
    private void checkRadiusCircle()
    {
        if (m_currentRadius <= m_minRadius) m_currentRadius = m_minRadius;
        if (m_currentRadius >= m_maxRadius) m_currentRadius = m_maxRadius;
        if (m_SpeedCircle <= m_minSpeedCircle) m_SpeedCircle = m_minSpeedCircle;
        if (m_SpeedCircle >= m_maxSpeedCircle) m_SpeedCircle = m_maxSpeedCircle;
    }
}
