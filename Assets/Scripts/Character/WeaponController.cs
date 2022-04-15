using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class WeaponController : MonoBehaviour
{
    [SerializeField]
    private Weapon m_weapon;

    [SerializeField]
    private string m_enemyTag;

    [SerializeField]
    private float m_maxFirePower;

    [SerializeField]
    private float m_firePowerSpeed;

    private float m_firePower;

    [SerializeField]
    private float m_rotateSpeed;
    //[SerializeField]
    //private float m_minRotation;

    //[SerializeField]
    //private float m_maxRotation;

    //private float m_mouseY;

    private bool m_fire;

    [Header("Crosshair reticle")]
    [SerializeField]
    private UI_Manager m_UI;

    [SerializeField]
    private float m_minRadius;

    [SerializeField]
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
    private PlayerInput playerInput;
    private InputAction m_shootArrow;

    private void Awake()
    {
        playerInput = GetComponent<PlayerInput>();
        m_shootArrow = playerInput.actions["Shoot"];
        m_weapon.SetEnemyTag(UtilsGyromitra.SearchForTag(m_enemyTag));
        m_weapon.Reload();
        m_fire = false;

        m_minRadius = 100f;
        m_currentRadius = 200f;
        m_maxRadius = 200f;
        m_Steps = 2000;
        m_SpeedCircle = 5f;
        m_maxSpeedCircle = 200f;
        m_minSpeedCircle = 100f;

    }

    private void Update()
    {
        // canviar la posicio del arc depenent de la posicio del ratoli // EN TEORIA JA FET EN EL CHARACTER CONTROLLER
        /*
        m_mouseY -= Input.GetAxis("Mouse Y") * m_rotateSpeed;
        m_mouseY = Mathf.Clamp(m_mouseY, m_minRotation, m_maxRotation);
        m_weapon.transform.localRotation = Quaternion.Euler(m_mouseY, m_weapon.transform.localEulerAngles.y, m_weapon.transform.localEulerAngles.z);
        */

        if (m_shootArrow.triggered)
        {
            m_fire = true;
        }

        if (m_fire)
        {
            if (m_firePower < m_maxFirePower)
            {
                m_firePower += Time.deltaTime * m_firePowerSpeed;
            }

            m_SpeedCircle += Time.deltaTime * 40f;
            m_currentRadius -= Time.deltaTime * m_SpeedCircle;
        }
        else
        {
            m_SpeedCircle -= Time.deltaTime * 50f;
            m_currentRadius += Time.deltaTime * m_SpeedCircle;
        }

        if (m_shootArrow.WasReleasedThisFrame())
        {
            m_weapon.FireArrow(m_firePower);
            m_firePower = 0f;
            m_fire = false;
        }

        checkRadiusCircle();

        m_UI.DrawCircle(m_Steps, m_currentRadius);
    }

    private void checkRadiusCircle()
    {
        if (m_currentRadius < m_minRadius) m_currentRadius = m_minRadius;
        if (m_currentRadius > m_maxRadius) m_currentRadius = m_maxRadius;
        if (m_SpeedCircle < m_minSpeedCircle) m_SpeedCircle = m_minSpeedCircle;
        if (m_SpeedCircle > m_maxSpeedCircle) m_SpeedCircle = m_maxSpeedCircle;
    }
}
